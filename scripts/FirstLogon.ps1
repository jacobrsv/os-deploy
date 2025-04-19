$scripts = @(
	{
		Set-ItemProperty -LiteralPath 'Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoLogonCount' -Type 'DWord' -Force -Value 0;
	};
	{
		Disable-ComputerRestore -Drive 'C:\';
	};
	{
		cmd.exe /c "rmdir C:\Windows.old";
	};
	{
		Get-Content -LiteralPath 'C:\Windows\Setup\Scripts\GetComputerName.ps1' -Raw | Invoke-Expression > 'C:\Windows\Setup\Scripts\ComputerName.txt';
		Start-Process -FilePath ( Get-Process -Id $PID ).Path -ArgumentList '-NoProfile', '-Command', 'Get-Content -LiteralPath "C:\Windows\Setup\Scripts\SetComputerName.ps1" -Raw | Invoke-Expression;' -WindowStyle 'Hidden';
		Start-Sleep -Seconds 10;
	};
    {
		Invoke-RestMethod -Uri 'http://osdeploy.internal:8000/scripts/firstrun.ps1' | Invoke-Expression;
	};
);

& {
  [float] $complete = 0;
  [float] $increment = 100 / $scripts.Count;
  foreach( $script in $scripts ) {
    Write-Progress -Activity 'Running scripts to finalize your Windows installation. Do not close this window.' -PercentComplete $complete;
    '*** Will now execute command «{0}».' -f $(
      $str = $script.ToString().Trim() -replace '\s+', ' ';
      $max = 100;
      if( $str.Length -le $max ) {
        $str;
      } else {
        $str.Substring( 0, $max - 1 ) + '…';
      }
    );
    $start = [datetime]::Now;
    & $script;
    '*** Finished executing command after {0:0} ms.' -f [datetime]::Now.Subtract( $start ).TotalMilliseconds;
    "`r`n" * 3;
    $complete += $increment;
  }
} *>&1 >> "C:\Windows\Setup\Scripts\FirstLogon.log";
