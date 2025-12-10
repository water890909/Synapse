function X1 {
    $a = 80
    $b = 40
    $c = 2.0
    $d = ' '
    $e = 20
    $f = 100
    $g = 0.5
    $h = 0; $i = 0; $j = 0
    $k = 0.03; $l = 0.02; $m = 0.04
    $n = @{X=0; Y=0; Z=-1}
    $o = [Math]::Sqrt($n.X*$n.X + $n.Y*$n.Y + $n.Z*$n.Z)
    $n.X /= $o
    $n.Y /= $o
    $n.Z /= $o
    $p = @(' ', '.', ':', '-', '=', '+', '*', '#', '@')
    $q = "$([char]27)"
    $r = @(
        ,(-$e, -$e, -$e)
        ,($e, -$e, -$e)
        ,($e,  $e, -$e)
        ,(-$e,  $e, -$e)
        ,(-$e, -$e,  $e)
        ,($e, -$e,  $e)
        ,($e,  $e,  $e)
        ,(-$e,  $e,  $e)
    ) | ForEach-Object { [pscustomobject]@{X=$_[0]; Y=$_[1]; Z=$_[2]} }
    $s = @(
        @(0, 3, 2, 1),
        @(1, 2, 6, 5),
        @(5, 6, 7, 4),
        @(4, 7, 3, 0),
        @(3, 7, 6, 2),
        @(4, 0, 1, 5)
    )
    function X2 {
        param($v1, $v2)
        return [pscustomobject]@{X = $v1.X - $v2.X; Y = $v1.Y - $v2.Y; Z = $v1.Z - $v2.Z}
    }
    function X3 {
        param($v1, $v2)
        return [pscustomobject]@{
            X = ($v1.Y * $v2.Z) - ($v1.Z * $v2.Y)
            Y = ($v1.Z * $v2.X) - ($v1.X * $v2.Z)
            Z = ($v1.X * $v2.Y) - ($v1.Y * $v2.X)
        }
    }
    function X4 {
        param($v)
        $mag = [Math]::Sqrt($v.X*$v.X + $v.Y*$v.Y + $v.Z*$v.Z)
        if ($mag -eq 0) { return $v }
        return [pscustomobject]@{X = $v.X / $mag; Y = $v.Y / $mag; Z = $v.Z / $mag}
    }
    function X5 {
        param($v1, $v2)
        return ($v1.X * $v2.X) + ($v1.Y * $v2.Y) + ($v1.Z * $v2.Z)
    }
    function X6 {
        param(
            [pscustomobject]$p1, [pscustomobject]$p2, [pscustomobject]$p3,
            [string]$char,
            [array]$buffer
        )
        $points = ($p1, $p2, $p3) | Sort-Object Y
        $v1 = $points[0]; $v2 = $points[1]; $v3 = $points[2]
        if ($v1.Y -eq $v3.Y) { return }
        if ($v1.Y -lt $v2.Y) {
            $slope1 = ($v3.X - $v1.X) / ($v3.Y - $v1.Y)
            $slope2 = ($v2.X - $v1.X) / ($v2.Y - $v1.Y)
            for ($y = $v1.Y; $y -lt $v2.Y; $y++) {
                $x1 = $v1.X + ($y - $v1.Y) * $slope1
                $x2 = $v1.X + ($y - $v1.Y) * $slope2
                X7 ([int]$x1) ([int]$x2) ([int]$y) $char $buffer
            }
        }
        if ($v2.Y -lt $v3.Y) {
            $slope1 = ($v3.X - $v1.X) / ($v3.Y - $v1.Y)
            $slope2 = ($v3.X - $v2.X) / ($v3.Y - $v2.Y)
            for ($y = $v2.Y; $y -le $v3.Y; $y++) {
                $x1 = $v1.X + ($y - $v1.Y) * $slope1
                $x2 = $v2.X + ($y - $v2.Y) * $slope2
                X7 ([int]$x1) ([int]$x2) ([int]$y) $char $buffer
            }
        } 
        elseif ($v1.Y -lt $v2.Y) { 
            $y = $v2.Y
            $slope1 = ($v3.X - $v1.X) / ($v3.Y - $v1.Y)
            $slope2 = ($v2.X - $v1.X) / ($v2.Y - $v1.Y)
            $x1 = $v1.X + ($y - $v1.Y) * $slope1
            $x2 = $v1.X + ($y - $v1.Y) * $slope2
            X7 ([int]$x1) ([int]$x2) ([int]$y) $char $buffer
        }
    }
    function X7 {
        param([int]$x1, [int]$x2, [int]$y, [string]$char, [array]$buffer)
        if ($y -lt 0 -or $y -ge $b) { return }
        $startX = [Math]::Max([Math]::Min($x1, $x2), 0)
        $endX = [Math]::Min([Math]::Max($x1, $x2), $a - 1)
        for ($x = $startX; $x -le $endX; $x++) {
            $buffer[$y][$x] = $char
        }
    }
    $t = for ($i = 0; $i -lt $b; $i++) { ,($d * $a).ToCharArray() }
    $u = ($d * $a).ToCharArray()
    $v = [System.Text.StringBuilder]::new($a * $b * 2)
    try {
        Write-Host -NoNewline "$q[?25l"; Clear-Host
        while ($true) {
            if ([System.Console]::KeyAvailable) {
                $w = [System.Console]::ReadKey($true)
                if ($w.Key -eq 'Escape') {
                    return
                }
            }
            for ($y = 1; $y -lt $b; $y++) { $u.CopyTo($t[$y], 0) }
            $x1 = [Math]::Sin($h); $x2 = [Math]::Cos($h)
            $y1 = [Math]::Sin($i); $y2 = [Math]::Cos($i)
            $z1 = [Math]::Sin($j); $z2 = [Math]::Cos($j)
            $w1 = @{}
            $w2 = @{}
            for ($idx = 0; $idx -lt $r.Count; $idx++) {
                $w3 = $r[$idx]
                $x3_rot_Y = $w3.X * $y2 - $w3.Z * $y1
                $z3_rot_Y = $w3.X * $y1 + $w3.Z * $y2
                $y3_rot_X = $w3.Y * $x2 - $z3_rot_Y * $x1
                $z3_rot_X = $w3.Y * $x1 + $z3_rot_Y * $x2
                $x3Final = $x3_rot_Y * $z2 - $y3_rot_X * $z1
                $y3Final = $x3_rot_Y * $z1 + $y3_rot_X * $z2
                $z3Final = $z3_rot_X
                $w1[$idx] = [pscustomobject]@{X=$x3Final; Y=$y3Final; Z=$z3Final}

                $factor = $f / ($f + $z3Final)
                $x3 = [int]($x3Final * $factor * $g * $c + $a / 2)
                $y3 = [int]($y3Final * $factor * $g + $b / 2)
                $w2[$idx] = [pscustomobject]@{X=$x3; Y=$y3}
            }
            $w4 = [System.Collections.ArrayList]::new()
            foreach ($faceIndices in $s) {
                $w5 = $w1[$faceIndices[0]]
                $w6 = $w1[$faceIndices[1]]
                $w7 = $w1[$faceIndices[2]]
                $w8 = X2 $w6 $w5
                $w9 = X2 $w7 $w5
                $w10 = X3 $w8 $w9
                if ($w10.Z -ge 0) { continue }
                $w11 = X4 $w10
                $w12 = X5 $w11 $n
                $w13 = [int](($w12 + 1) / 2 * ($p.Length - 1))
                if ($w13 -lt 0) {$w13 = 0}
                if ($w13 -ge $p.Length) {$w13 = $p.Length - 1}
                $w14 = $p[$w13]
                $w15 = ($w5.Z + $w6.Z + $w7.Z + $w1[$faceIndices[3]].Z) / 4
                [void]$w4.Add([pscustomobject]@{
                    P1 = $w2[$faceIndices[0]]
                    P2 = $w2[$faceIndices[1]]
                    P3 = $w2[$faceIndices[2]]
                    P4 = $w2[$faceIndices[3]]
                    Z  = $w15
                    Char = $w14
                })
            }
            $w16 = $w4 | Sort-Object Z -Descending
            foreach ($w17 in $w16) {
                X6 $w17.P1 $w17.P2 $w17.P3 $w17.Char $t
                X6 $w17.P1 $w17.P3 $w17.P4 $w17.Char $t
            }
            [void]$v.Clear()
            [void]$v.Append("$q[H")
            foreach ($w18 in $t) {
                [void]$v.Append($w18)
                [void]$v.Append("`n")
            }
            [System.Console]::Write($v.ToString())
            $h += $k; $i += $l; $j += $m
            Start-Sleep -Milliseconds 66
        }
    }
    finally {
        Write-Host -NoNewline "$q[?25h"; Clear-Host
    }
}