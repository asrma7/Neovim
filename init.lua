-- Change current working directory to the argument if it is a directory
vim.cmd([[if argc() == 1 && isdirectory(argv(0)) | cd `=argv(0)` | endif]])

require("asrma7")
