call my#compat#require('internal')

if g:_my_general_offline
  call my#compat#vim_source('viml/subsrc')
else
  call my#compat#require('packages')
endif
