<#
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2022 Norgate AV Solutions Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

function Export-DeviceRuntimeInfo {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]
        $Device,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]
        $ExcelParams
    )

    process {
        $deviceDirectory = $Device.DeviceDirectory
        New-Item -Path $deviceDirectory -Type Directory -Force | Out-Null

        if ($Device.RuntimeInfo) {
            $runtimeInfoFile = Join-Path -Path $deviceDirectory -ChildPath "RuntimeInfo.txt"
            $Device.RuntimeInfo | Out-File -FilePath $runtimeInfoFile -Force
        }

        if ($Device.ProgramInfo) {
            $programInfoFile = Join-Path -Path $deviceDirectory -ChildPath "Programs.xlsx"
            $Device.ProgramInfo | Export-Excel -Path $programInfoFile @ExcelParams
            Write-Verbose "notice: [$($Device.Device)] => Program Count: $($Device.ProgramInfo.Count)"
        }

        if ($Device.IPTableInfo) {
            $ipTableInfoFile = Join-Path -Path $deviceDirectory -ChildPath "IPTables.xlsx"
            $Device.IPTableInfo | Export-Excel -Path $ipTableInfoFile @ExcelParams
        }

        if ($Device.ControlSubnetInfo) {
            $controlSubnetInfoFile = Join-Path -Path $deviceDirectory -ChildPath "ControlSubnet.xlsx"
            $Device.ControlSubnetInfo.DhcpLeases | Export-Excel -Path $controlSubnetInfoFile -WorksheetName "DhcpLeases" @ExcelParams
            $Device.ControlSubnetInfo.ReservedLeases | Export-Excel -Path $controlSubnetInfoFile -WorksheetName "ReservedLeases" @ExcelParams
            Write-Verbose "notice: [$($Device.Device)] => Control Subnet DHCP Lease Count: $($Device.ControlSubnetInfo.DhcpLeases.Count)"
            Write-Verbose "notice: [$($Device.Device)] => Control Subnet Reserved Lease Count: $($Device.ControlSubnetInfo.ReservedLeases.Count)"
            $Device.ControlSubnetInfo.PortMap | Export-Excel -Path $controlSubnetInfoFile -WorksheetName "PortMap" @ExcelParams
        }

        if ($Device.CresnetInfo) {
            $cresnetInfoFile = Join-Path -Path $deviceDirectory -ChildPath "CresnetInfo.xlsx"
            $Device.CresnetInfo | Export-Excel -Path $cresnetInfoFile @ExcelParams
            Write-Verbose "notice: [$($Device.Device)] => Cresnet Device Count: $(@($Device.CresnetInfo).Count)"
        }
    }
}
