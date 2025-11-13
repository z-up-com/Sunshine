@echo off

set RULE_NAME=Streaming

rem Delete the rule
netsh advfirewall firewall delete rule name=%RULE_NAME%
