$BaseUrl = if ($env:HTTP_TEST_BASE_URL) { $env:HTTP_TEST_BASE_URL.TrimEnd("/") } else { "https://horusquest.com" }

$checks = @(
  @{ Path = "/oraquest/"; Status = 200 },
  @{ Path = "/guessora/"; Status = 200 },
  @{ Path = "/oraguess/"; Status = 301; Location = "https://horusquest.com/guessora/" },
  @{ Path = "/oraguess"; Status = 301; Location = "https://horusquest.com/guessora/" }
)

foreach ($check in $checks) {
  $url = "$BaseUrl$($check.Path)"
  $response = curl.exe -I -s -o NUL -w "%{http_code}|%{redirect_url}" $url
  $parts = $response.Split("|")
  $status = [int]$parts[0]
  $location = if ($parts.Length -gt 1) { $parts[1] } else { "" }

  if ($status -ne $check.Status) {
    throw "$($check.Path): expected $($check.Status), got $status"
  }

  if ($check.Location -and $location -ne $check.Location) {
    throw "$($check.Path): expected Location $($check.Location), got $location"
  }

  Write-Host "ok $($check.Path) -> $status"
}
