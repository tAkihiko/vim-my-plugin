scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

command! -nargs=1 GetRedmineIssueDescription call tanikawa#redmine#GetRedmineIssueDescription(<f-args>)
command! -nargs=1 GetRedmineIssueURLandTitle call tanikawa#redmine#GetRedmineIssueURLandTitle(<f-args>)
command! -nargs=+ MkRedmineDiffCommit call tanikawa#redmine#MakeRedmineDiffCommit(<f-args>)
command! -nargs=+ -complete=custom,tanikawa#redmine#GetRedmineGitBranch MkRedmineDiffBranch call tanikawa#redmine#MakeRedmineDiffBranch(<f-args>)
