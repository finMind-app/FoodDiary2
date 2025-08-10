@echo off
rem Copy to actions_env.bat and fill in your values

rem OWNER/REPO
set GH_REPO=owner/repo

rem GitHub Personal Access Token with repo and workflow scopes
set GH_TOKEN=ghp_your_token_here

rem Workflow file name as seen in .github/workflows
set WORKFLOW_FILE=ios-build.yml

rem Git ref to dispatch (branch or tag)
set GIT_REF=main


