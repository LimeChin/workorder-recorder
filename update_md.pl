#!/usr/bin/perl
use strict;
use warnings;

# 参数
my ($target_file, $commit_hash, $commit_msg, $commit_author, $commit_date, $branch, $workorder, $ai_summary, $git_diff, $files_str) = @ARGV;

# 清理参数末尾的空白字符
$ai_summary =~ s/\s+$//;
$git_diff =~ s/\s+$//;

my @files = split(/\n/, $files_str // "");

# 读取现有文件内容
my $existing_content = "";
if (-f $target_file) {
    local $/;
    open(my $fh, '<', $target_file) or die "Cannot read $target_file: $!";
    $existing_content = <$fh>;
    close($fh);
}

# 解析已有的提交记录
my @all_commits;
if ($existing_content =~ /## 📝 提交历史/s) {
    # 提取所有已有的提交记录（更健壮的正则）
    while ($existing_content =~ /### 提交 (\w+) \(([^)]+)\)\n\*\*作者:\*\* ([^\n]+)\n\*\*改动:\*\* ([^\n]+(?:\n(?!###|\*\*Diff:\*\*)[^\n]*)*)\s*\n\*\*Diff:\*\*\s*\n```diff\n(.*?)```/gs) {
        push @all_commits, {
            hash => $1,
            date => $2,
            author => $3,
            summary => $4,
            diff => $5
        };
    }
}

# 添加本次提交到开头（最新的在前）
unshift @all_commits, {
    hash => $commit_hash,
    date => $commit_date,
    author => $commit_author,
    summary => $ai_summary,
    diff => $git_diff
};

# 构建改动表格
my $changes_table = "| 提交 | 文件 | 改动 | 时间 |\n|------|------|------|------|\n";
for my $c (@all_commits) {
    my $short_summary = substr($c->{summary}, 0, 50);
    $short_summary .= "..." if length($c->{summary}) > 50;
    my $short_time = substr($c->{date}, 0, 16);
    my $file_names = join(", ", map { s/.*\///r } @files);
    $changes_table .= "| $c->{hash} | $file_names | $short_summary | $short_time |\n";
}

# 构建历史区
my $history_content = "";
for my $c (@all_commits) {
    $history_content .= <<"END";

### 提交 $c->{hash} ($c->{date})
**作者:** $c->{author}
**改动:** $c->{summary}

**Diff:**
\`\`\`diff
$c->{diff}
\`\`\`

---
END
}

# 生成完整文件内容
my $new_content = <<"END";
# $commit_msg

## 📊 当前状态

**最新更新:** $commit_date
**分支:** $branch
**工单:** $workorder
**完成度:** 进行中

### 已完成的改动

$changes_table
---

## 📝 提交历史
$history_content
END

open(my $fh, '>', $target_file) or die "Cannot write $target_file: $!";
print $fh $new_content;
close($fh);

print "Updated: $target_file\n";