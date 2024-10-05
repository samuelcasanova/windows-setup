. ./support-files/utils.ps1

$o = new-object -com shell.application
$o.Namespace('C:\Users\alexc\OneDrive\Samuel\Ocio personal\Proyectos Personales').Self.InvokeVerb("pintohome")
$o.Namespace('C:\Users\samue\OneDrive\Peques').Self.InvokeVerb("pintohome")
$o.Namespace('C:\Users\samue\OneDrive\Samuel\Desarrollo personal').Self.InvokeVerb("pintohome")
$o.Namespace('C:\Users\samue\OneDrive\Samuel\Ocio personal').Self.InvokeVerb("pintohome")

Set-KnownFolderPath -KnownFolder 'Documents' -Path 'C:\Users\alexc\OneDrive\Documentos'
Set-KnownFolderPath -KnownFolder 'Pictures' -Path 'C:\Users\alexc\OneDrive\Imágenes'
Set-KnownFolderPath -KnownFolder 'Music' -Path 'C:\Users\alexc\OneDrive\Música'
Set-KnownFolderPath -KnownFolder 'Videos' -Path 'C:\Users\alexc\OneDrive\Vídeos'
