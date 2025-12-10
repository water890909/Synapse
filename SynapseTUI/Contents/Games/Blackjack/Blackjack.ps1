<#
Simple Blackjack (Console) - PowerShell
Features:
- Full 52-card deck, shuffling
- Player vs dealer, hit/stand
- Correct Ace handling (1 or 11)
- Betting system with bankroll
- Dealer hits on 16 or less, stands on 17+ (soft 17 treated as 17)
- Round loop, quit anytime with "q"
#>

# ----- Utility functions -----
function New-Deck {
    $suits = 'S', 'H', 'D', 'C'
    $ranks = 2..10 + 'J', 'Q', 'K', 'A'
    $deck = @()
    foreach ($s in $suits) {
        foreach ($r in $ranks) {
            $deck += [PSCustomObject]@{Rank = $r; Suit = $s; Code = "$r$s" }
        }
    }
    return , $deck
}

function Shuffle-Deck {
    param([ref]$deck)
    # Fisher-Yates
    $rand = [System.Random]::new()
    for ($i = $deck.Value.Count - 1; $i -gt 0; $i--) {
        $j = $rand.Next(0, $i + 1)
        $tmp = $deck.Value[$i]; $deck.Value[$i] = $deck.Value[$j]; $deck.Value[$j] = $tmp
    }
}

function Draw-Card {
    param([ref]$deck)
    if ($deck.Value.Count -eq 0) { throw "Deck is empty" }
    $card = $deck.Value[0]
    $deck.Value = $deck.Value[1..($deck.Value.Count - 1)]
    return $card
}

function Hand-Value {
    param([array]$hand)
    # Sum numeric values and account for Aces
    $total = 0
    $aces = 0
    foreach ($c in $hand) {
        switch ($c.Rank) {
            { $_ -in 2..10 } { $total += [int]$c.Rank }
            'J' { $total += 10 }
            'Q' { $total += 10 }
            'K' { $total += 10 }
            'A' { $aces++; $total += 11 } # treat as 11 for now
        }
    }
    # Downgrade aces from 11 to 1 as needed
    while ($total -gt 21 -and $aces -gt 0) {
        $total -= 10
        $aces--
    }
    return $total
}

function Show-Hand {
    param(
        [string]$who,
        [array]$hand,
        [switch]$hideFirst
    )
    if ($hideFirst) {
        $cards = @("[hidden]") + ($hand[1..($hand.Count - 1)] | ForEach-Object { $_.Code })
        $display = ($cards -join ' ')
        Write-Host "${who}: $display"
    }
    else {
        $display = ($hand | ForEach-Object { $_.Code }) -join ' '
        $value = Hand-Value -hand $hand
        Write-Host "${who}: $display  --  ($value)"
    }
}


function Prompt-Number {
    param([string]$prompt, [int]$min = 1, [int]$max = [int]::MaxValue)
    while ($true) {
        $input = Read-Host $prompt
        if ($input -eq 'quit') { exit }

        $n = 0   # declare $n before using it
        if ([int]::TryParse($input, [ref]$n)) {
            if ($n -ge $min -and $n -le $max) { return $n }
        }

        Write-Host "Enter a number between $min and $max" -ForegroundColor Yellow
    }
}


# ----- Game logic -----


$bankroll = 100     # initial bankroll
function Play-Round {
    param(
        [ref]$bankroll,
        [int]$minBet = 1
    )

    if ($bankroll.Value -lt $minBet) {
        Write-Host "You don't have enough money to continue." -ForegroundColor Red
        return $false
    }

    $maxBet = $bankroll.Value
    $inputBet = Prompt-Number -prompt "Place your bet (min $minBet, max $maxBet). -min $minBet -max $maxBet"
    if ($inputBet -eq 'q') { return 'q' }
    $stake = [int]$inputBet

    # Deduct the initial stake immediately (simplifies payout logic)
    $bankroll.Value -= $stake

    # Prepare deck
    $deck = New-Deck
    $deckRef = [ref]$deck
    Shuffle-Deck -deck $deckRef

    $playerHand = @()
    $dealerHand = @()

    # Initial deal
    $playerHand += Draw-Card -deck $deckRef
    $dealerHand += Draw-Card -deck $deckRef
    $playerHand += Draw-Card -deck $deckRef
    $dealerHand += Draw-Card -deck $deckRef

    Write-Host "`n--- New Round ---"
    Show-Hand -who "Dealer" -hand $dealerHand -hideFirst
    Show-Hand -who "Player" -hand $playerHand

    # Immediate blackjack checks
    $playerValue = Hand-Value -hand $playerHand
    $dealerValue = Hand-Value -hand $dealerHand

    $playerBlackjack = ($playerHand.Count -eq 2 -and $playerValue -eq 21)
    $dealerBlackjack = ($dealerHand.Count -eq 2 -and $dealerValue -eq 21)

    if ($playerBlackjack -or $dealerBlackjack) {
        Show-Hand -who "Dealer" -hand $dealerHand
        if ($playerBlackjack -and -not $dealerBlackjack) {
            Write-Host "Blackjack! You win 3:2 payout." -ForegroundColor Green
            $payout = [math]::Floor($stake * 2.5)   # return stake + 1.5x winnings
            $bankroll.Value += $payout
            return $true
        }
        elseif (-not $playerBlackjack -and $dealerBlackjack) {
            Write-Host "Dealer has blackjack. You lose the bet." -ForegroundColor Red
            # stake already deducted
            return $true
        }
        else {
            Write-Host "Both have blackjack. Push (tie)." -ForegroundColor Cyan
            $bankroll.Value += $stake
            return $true
        }
    }

    # Player turn
    $playerDone = $false
    while (-not $playerDone) {
        $playerValue = Hand-Value -hand $playerHand
        if ($playerValue -gt 21) {
            Show-Hand -who "Player" -hand $playerHand
            Write-Host "Bust! You lose the stake of $stake." -ForegroundColor Red
            # stake already deducted
            return $true
        }

        $choice = Read-Host "Hit (h) / Stand (s) / Double Down (d) / Quit (q). Bankroll:$($bankroll.Value) Wager:$stake"
        if (-not $choice) { continue }

        switch ($choice.ToLower()) {
            'h' {
                $playerHand += Draw-Card -deck $deckRef
                Show-Hand -who "Player" -hand $playerHand
                continue
            }
            's' {
                $playerDone = $true
                break
            }
            'd' {
                # Only allow double-down on the first action (two-card hand)
                if ($playerHand.Count -ne 2) {
                    Write-Host "Double down only allowed on your first two cards." -ForegroundColor Yellow
                    continue
                }
                if ($bankroll.Value -lt $stake) {
                    Write-Host "Not enough bankroll to double down." -ForegroundColor Yellow
                    continue
                }
                # Deduct the additional equal stake and update total wager
                $bankroll.Value -= $stake
                $stake = $stake * 2

                # Take one card and then stand
                $playerHand += Draw-Card -deck $deckRef
                Show-Hand -who "Player" -hand $playerHand
                $playerValue = Hand-Value -hand $playerHand
                if ($playerValue -gt 21) {
                    Show-Hand -who "Player" -hand $playerHand
                    Write-Host "Bust after double down! You lose the stake of $stake." -ForegroundColor Red
                    return $true
                }
                $playerDone = $true
                break
            }
            'q' {
                # Refund stake if quitting mid-hand, then quit game
                $bankroll.Value += $stake
                return 'q'
            }
            default {
                Write-Host "Invalid option. Use h, s, d or q." -ForegroundColor Yellow
                continue
            }
        }
    }

    # Dealer turn - reveal and play
    Write-Host "`nDealer reveals..."
    Show-Hand -who "Dealer" -hand $dealerHand

    while ($true) {
        $dealerValue = Hand-Value -hand $dealerHand
        if ($dealerValue -le 16) {
            Write-Host "Dealer hits." -ForegroundColor Magenta
            $dealerHand += Draw-Card -deck $deckRef
            Show-Hand -who "Dealer" -hand $dealerHand
            Start-Sleep -Milliseconds 1000
            continue
        }
        else {
            Write-Host "Dealer stands." -ForegroundColor Yellow
            break
        }
    }

    $playerValue = Hand-Value -hand $playerHand
    $dealerValue = Hand-Value -hand $dealerHand

    Show-Hand -who "Player" -hand $playerHand
    Show-Hand -who "Dealer" -hand $dealerHand

    if ($dealerValue -gt 21) {
        Write-Host "Dealer busts. You win!" -ForegroundColor Green
        $bankroll.Value += ($stake * 2)
    }
    elseif ($playerValue -gt $dealerValue) {
        Write-Host "You win!" -ForegroundColor Green
        $bankroll.Value += ($stake * 2)
    }
    elseif ($playerValue -lt $dealerValue) {
        Write-Host "You lose." -ForegroundColor Red
        # stake already lost
    }
    else {
        Write-Host "Push (tie)." -ForegroundColor Cyan
        $bankroll.Value += $stake
    }

    return $true
}


# ----- Main -----
function Start-Blackjack {
    Clear-Host
    Write-Host "PowerShell Blackjack - type 'quit' at prompts to quit." -ForegroundColor Cyan
    $script:bankroll = $bankroll
    $minBet = 1

    while ($bankroll -gt 0) {
        Write-Host "`nBankroll: $bankroll"
        $res = Play-Round -bankroll ([ref]$bankroll) -minBet $minBet

        if ($res -eq 'q') { break }   # player chose to quit
        # no need to check bankroll inside loop, the while condition handles it
        Start-Sleep -Seconds 1
        Clear-Host
    }

    if ($bankroll -le 0) {
        Write-Host "You're broke. Game over." -ForegroundColor Red
    }
    else {
        Start-Sleep -Seconds 1
        Pause
        Start-Blackjack
    }
    Pause
}



# Run
Start-Blackjack
