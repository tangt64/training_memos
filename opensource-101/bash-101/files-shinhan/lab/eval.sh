a='$b'
b='$c'
c=d

echo $a             # $b
                    # First level.
eval echo $a        # $c
                    # Second level.
eval eval echo $a   # d
                    # Third level.

