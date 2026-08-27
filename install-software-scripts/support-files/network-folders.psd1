@{
    Server = '192.168.1.2'

    Users = @{
        samuel = @{
            Folders = @{
                Documents = '\\192.168.1.2\Samuel\Documents'
                Music     = '\\192.168.1.2\Music\samuel\Music'
                Pictures  = '\\192.168.1.2\Pictures'
                Videos    = '\\192.168.1.2\Videos'
            }
            QuickAccess = @(
                '\\192.168.1.2\Samuel\Documents'
                '\\192.168.1.2\Pictures'
            )
        }

        judit = @{
            Folders = @{
                Documents = '\\192.168.1.2\Judit\Documents'
                Music     = '\\192.168.1.2\Music\judit\Music'
                Pictures  = '\\192.168.1.2\Pictures'
                Videos    = '\\192.168.1.2\Videos'
            }
            QuickAccess = @(
                '\\192.168.1.2\Judit\Documents'
                '\\192.168.1.2\Pictures'
            )
        }

        victor = @{
            Folders = @{
                Documents = '\\192.168.1.2\Victor\Documents'
                Music     = '\\192.168.1.2\Music\victor\Music'
                Pictures  = '\\192.168.1.2\Pictures'
                Videos    = '\\192.168.1.2\Videos'
            }
            QuickAccess = @(
                '\\192.168.1.2\Victor\Documents'
                '\\192.168.1.2\Pictures'
            )
        }

        alex = @{
            Folders = @{
                Documents = '\\192.168.1.2\Alex\Documents'
                Music     = '\\192.168.1.2\Music\alex\Music'
                Pictures  = '\\192.168.1.2\Pictures'
                Videos    = '\\192.168.1.2\Videos'
            }
            QuickAccess = @(
                '\\192.168.1.2\Alex\Documents'
                '\\192.168.1.2\Pictures'
            )
        }
    }
}
