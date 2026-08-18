/* Reglas pequeñas y auditables para triage offline. Una coincidencia es un
   indicador para revisar, no una afirmación automática de malware. */

rule HaNiX_Private_Key_Material
{
    meta:
        description = "Material de clave privada incrustado"
    strings:
        $pem_rsa = "-----BEGIN RSA PRIVATE KEY-----" ascii
        $pem_ec  = "-----BEGIN EC PRIVATE KEY-----" ascii
        $pem_pk8 = "-----BEGIN PRIVATE KEY-----" ascii
    condition:
        any of them
}

rule HaNiX_Suspicious_PowerShell_Encoded_Command
{
    meta:
        description = "Invocación PowerShell con comando codificado"
    strings:
        $powershell = "powershell" ascii wide nocase
        $encoded_1  = "-EncodedCommand" ascii wide nocase
        $encoded_2  = "-enc " ascii wide nocase
    condition:
        $powershell and any of ($encoded_*)
}

rule HaNiX_Common_PHP_Webshell_Primitives
{
    meta:
        description = "Combinación de primitivas frecuente en webshells PHP"
    strings:
        $eval   = "eval(" ascii nocase
        $system = "system(" ascii nocase
        $input1 = "$_POST[" ascii nocase
        $input2 = "$_REQUEST[" ascii nocase
    condition:
        any of ($input*) and any of ($eval, $system)
}
