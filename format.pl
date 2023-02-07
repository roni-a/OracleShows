#!/usr/contrib/bin/perl
#
# Usage: perl format.pl < tmp.lst
#
%x =   ("DELETE", "\n -- \n", "END;", "\n", ",", "\n      ", "SELECT", "\n ", "BEGIN", "\n", "UPDATE", "\n ", "MERGE", "\n -- \n", "WHEN", "\n\t   ", "INSERT", "\n -- \n",\
      	"WHERE", "   ", "FROM", "   ", "INTO", "   ", "MINUS", "  ", "WHERE", "  ", "AND", "    ", "SET", "    ", "END", "\n\t",\
      	"OR", "     ", "GROUP", "  ", "ORDER", "  ", "UNION", "  ", "newline", "        ", "ELSE", "\n\t   ", "INNER", "\n\t", "ON", "\n\t\t",\
      	",, ", "\n       ", "GRANT", "\n", "CREATE","\n", "ALTER", "\n", "LEFT", "\n\t");
while (<>) {
    s/\,/\, /g; #Multi-space removed later.
    s/\"/\" /g;
    s/=/ = /g;
    s/>:/> :/g;
    s/\(/ \(/g;
    s/\)/\) /g;
    s/>/ > /g;
    s/\s+/ /g;
    s/ ,/,/g;
    s/^ //g;
    s/= >/=>/g;
    s/FROM/ FROM/g;
    s/ and / AND /g;
    s/ in / IN /g;
    s/ when / WHEN /g;
    s/ then / THEN /g;
    s/ else / ELSE /g;
    s/ end/ END/g;
    s/ upper \(/ UPPER\(/g;
    s/ upper\(/ UPPER\(/g;
    s/ lower \(/ LOWER\(/g;
    s/ lower\(/ LOWER\(/g;
    s/\(case /\(CASE /g;
    s/ sum \(/ SUM\(/g;
    s/ sum\(/ SUM\(/g;
    s/, / , /g;
    s/, '/,'/g;
    s/SYSDATE , /SYSDATE, /g;
    s/BEGIN/; BEGIN/g;
    s/DELETE/ DELETE/g;
    s/SELECT/ SELECT/g;
    s/ SELECT/ SELECT /g;
    s/_ SELECT/_SELECT/g;
    s/_SELECT /_SELECT/g;
    s/INSERT/ INSERT/g;
    s/LEFT JOIN/ LEFT JOIN/g;
    s/RIGHT JOIN/ RIGHT JOIN/g;
    s/UPDATE/ UPDATE/g;
    s/_ UPDATE/_UPDATE/g;
    s/THEN'/THEN '/g;
    s/NOWAIT/NOWAIT /g;
    s/COUNT \(/COUNT\(/g;
    s/\( \(/\(\(/g;
    s/\) \)/\)\)/g;
    s/\(\( \(/\(\(\(/g;
    s/\)\) \)/\)\)\)/g;
    s/TRUNC \(/TRUNC\(/g;
    s/ \)/\)/g;
    s/! = / != /g;
    s/> =/>=/g;
    s/< =/<=/g;
    s/< >/<>/g;
    s/NVL \(/NVL\(/g;
    s/DECODE \(/DECODE\(/g;
    $buf .= $_;
    }

    @words = split (/\s/,$buf);

    foreach $word (@words) {
      if (defined( $x{$word} )) {
        print "$line\n";
        $line = $x{$word}.$word;
        } else {
          $line = $line . " " . $word;
        }
      }
      print "$line ; \n";

    print " \n";
