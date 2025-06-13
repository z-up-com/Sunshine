set -e

read -rp "Build type? (1=Release, 2=Test): " TYPE

if [[ "$TYPE" == "2" ]]; then
  read -rp "Enter test version: " VER
  export BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  export BUILD_VERSION="$VER"
  export COMMIT="$(git rev-parse --short HEAD)"
  export BUILD_TYPE="debug"

elif [[ "$TYPE" == "1" ]]; then
  LATEST_TAG=$(git describe --tags --abbrev=0)
  TAG_COMMIT=$(git rev-list -n 1 "$LATEST_TAG")
  CURRENT_COMMIT=$(git rev-parse HEAD)

  if [[ "$TAG_COMMIT" != "$CURRENT_COMMIT" ]]; then
    echo "Tag commit does not match current commit!"
    echo "Latest tag: $LATEST_TAG -> $TAG_COMMIT"
    echo "Current commit: $CURRENT_COMMIT"
    exit 1
  fi

  export BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  export BUILD_VERSION="${LATEST_TAG#v}"  # remove leading 'v' if exists
  export COMMIT="$(git rev-parse --short HEAD)"
  export BUILD_TYPE="release"

else
  echo "Invalid input"
  exit 1
fi

cmake -B build -S . \
  -DPROJECT_VERSION="$BUILD_VERSION" \
  -DBUILD_DOCS=OFF \
  -DBUILD_WERROR=ON

cmake --build build
