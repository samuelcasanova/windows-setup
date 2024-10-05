. ./support-files/utils.ps1

$o = new-object -com shell.application
$o.Namespace('C:\Users\samue\OneDrive\Samuel\Ocio personal\Proyectos Personales').Self.InvokeVerb("pintohome")
$o.Namespace('C:\Users\samue\OneDrive\Peques').Self.InvokeVerb("pintohome")
$o.Namespace('C:\Users\samue\OneDrive\Samuel\Desarrollo personal').Self.InvokeVerb("pintohome")
$o.Namespace('C:\Users\samue\OneDrive\Samuel\Ocio personal').Self.InvokeVerb("pintohome")

Set-KnownFolderPath -KnownFolder 'Documents' -Path 'C:\Users\samue\OneDrive\Samuel'
Set-KnownFolderPath -KnownFolder 'Pictures' -Path 'C:\Users\samue\OneDrive\Pictures'
Set-KnownFolderPath -KnownFolder 'Music' -Path 'C:\Users\samue\OneDrive\mp3\SAMUEL'
Set-KnownFolderPath -KnownFolder 'Videos' -Path 'C:\Users\samue\OneDrive\OwnVideos'
