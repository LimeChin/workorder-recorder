#!/usr/bin/perl
use strict;
use warnings;

my $json = <STDIN>;

# 找到 "text": 后的位置
if ($json =~ /"text"\s*:\s*"/) {
    my $pos = $+[0];  # 匹配结束位置
    my $text = "";
    my $i = $pos;
    while ($i < length($json)) {
        my $c = substr($json, $i, 1);
        if ($c eq "\\") {
            # 转义字符
            my $next = substr($json, $i+1, 1);
            if ($next eq "n") { $text .= "\n"; }
            elsif ($next eq "t") { $text .= "\t"; }
            elsif ($next eq "\"") { $text .= "\""; }
            elsif ($next eq "\\") { $text .= "\\"; }
            else { $text .= $next; }
            $i += 2;
        } elsif ($c eq "\"") {
            # 结束引号
            last;
        } else {
            $text .= $c;
            $i++;
        }
    }
    print $text;
}