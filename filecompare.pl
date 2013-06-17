##############################################################################
# 程式說明：                                              by heaven 2013/06/13
#     檔案比對，限 utf8 編碼，以「行」為比對單位，無法處理格式不同的檔案。
# 使用方法：
#     perl filecompare.pl -f1 檔案1 -f2 檔案2 -o 比對結果檔 
#          [-h -skip_item 忽略的項目 -skip 忽略的文字]
# 參數說明：
#     -f1 要比對的檔案1
#     -f2 要比對的檔案2
#     -o 比對結果
#     -h 列出說明
#     -skip_item 要忽略的項目
#        a : (a-z) 忽略小寫英文字母 a-z
#        A : (A-Z) 忽略大寫英文字母 A-Z
#        d : (digit) 忽略數字 0-9
#        h : (head) 忽略行首 T01n0001_p0001a01║
#        p : (punctuation) 忽略全型新式標點
#                          ，。、；：！？．—…「」『』（）《》〈〉“”
#        s : (space) 忽略半型空格
#        S : (Space) 忽略全部空格 (包含半型空格, 全型空格及 tab )
#        t : (tag) 忽略 <...> 角括號所包含的範圍
#     -skip 要忽略的文字。例如要忽略 abc及小括號 -skip abc()
#        
# 範例：
#     perl filecompare.pl -h
#     perl filecompare.pl -f1 a.txt -f2 b.txt -o c.txt -skip_item haApS 
#     perl filecompare.pl -f1=a.txt -f2=b.txt -o=c.txt -skip ，。「」
##############################################################################

use utf8;
use Encode;
use strict;
use autodie;
use Getopt::Long;
use vars qw($opt_f1 $opt_f2 $opt_o $opt_h $opt_skip $opt_skip_item);		# 如果有使用 use strict; , 本行就要加上去

############################################################
# 變數
############################################################

my $skipline = 10; # 差異超過此行就放棄

############################################################
# 檢查參數
############################################################

# 表示 -f1, -f2, -o 都要引數, 並放入 $opt_f1 , $opt_f2 , $opt_o
# -h 不用引數
# s : 字串 , i : 整數 , f : 浮點
GetOptions("f1=s", "f2=s", "o=s", "h!", "skip=s", "skip_item=s");	

if($opt_h == 1)
{
	print_help();
	exit;
}

print tobig5("\n【檔案比對程式】\n");

if($opt_f1 eq "")
{
	print tobig5("錯誤：沒有使用 -f1 參數\n");
	print_help();
	exit;
}
if($opt_f2 eq "")
{
	print tobig5("錯誤：沒有使用 -f2 參數\n");
	print_help();
	exit;
}
if($opt_o eq "")
{
	print tobig5("錯誤：沒有使用 -o 參數\n");
	print_help();
	exit;
}

# 要忽略的字是由 big5 環境傳入, 所以要先 decode
$opt_skip = decode("big5", $opt_skip);

print tobig5("檔案一   : $opt_f1\n");
print tobig5("檔案二   : $opt_f2\n");
print tobig5("比對結果 : $opt_o\n");

############################################################
# 主程式
############################################################

open OUT, ">:utf8", $opt_o;

compare($opt_f1 , $opt_f2);

print tobig5("處理完畢\n");

############################################################
# 檔案比對
############################################################

sub compare()
{
	my $file1 = shift;
	my $file2 = shift;
	
	my @orig_text1 = ();	# 儲存檔案的內容
	my @orig_text2 = ();
	my @text1 = ();	# 處理過忽略文字的檔案內容
	my @text2 = ();
	
	my $okline1 = -1;	# 在文章中的行數指標，表示目前二者內容相同的行數
	my $okline2 = -1;
	
	my $index1 = 0;	# 在文章中的行數指標，表示目前正要處理的行數。
	my $index2 = 0;

    # 指標示範
    #
	# 檔案一              檔案二
	# AAA                 AAA 
	# BBB $okline1=2      BBB $okline2=2
	# CCC $index1=3       XXX
	# DDD                 DDD $index2=4
	# EEE                 EEE
	#
	# 原本 $index2=3 , 但與 $index1=3 內容不同, 所以 $index2=4 向下移了一行

	
	# 讀取第一個檔案
	open IN, "<:utf8", $file1;
	while(<IN>)	{ push @orig_text1, $_; }
	close IN;
	
	# 讀取第二個檔案
	open IN, "<:utf8", $file2;
	while(<IN>)	{ push @orig_text2, $_; }
	close IN;
	
	# 若檔尾沒有換行, 則加上去
	$orig_text1[-1] .= "\n" if($orig_text1[-1] !~ /\n/);
	$orig_text2[-1] .= "\n" if($orig_text2[-1] !~ /\n/);
	
	# 將檔案忽略的內容處理後, 存到 @text 陣列中
	do_skip(\@orig_text1, \@text1);
	do_skip(\@orig_text2, \@text2);
	
	############################
	# 開始比對
	############################
	
	# 比對邏輯 :
	# 第一檔(A檔)第一行與第二檔(B檔)第一行比對.
	# 若相同就繼續
	# 若不同, A 檔第一行比對 B 檔第二行, 若不同比 B 檔第三行, 直到超過 10 行就放棄.
	# 換成 A 檔第二行比對 B 檔第一行, 若同比 B 檔第二行, 直到超過 10 行就放棄.
	# 換成 A 檔第三行.....
	# 若 A 檔第 10 行依然沒有找到 B 檔的某一行, 就全部放棄. (此處 10 行就是 $skipline 變數)
	
	while( ($index1 <= $#text1) and ($index2 <= $#text2) )
	{
		if($text1[$index1] eq $text2[$index2])
		{
			# 這二行相等, 要把之前不相等的各行印出來
			# 例如之前 A, B 檔是在 0, 0 行相等.
			# 現在是在 1, 3 行相等, 所以 A 檔不用印, B 檔要印出 1, 2 二行.
			
			# 這二行相同, 在之前若有不相同的差異, 就要印出來
			if(($index1 - $okline1 > 1) or ($index2 - $okline2 > 1))
			{
				# 印出來的樣子
				
				# 這一行是大家都有的
				# ▍▃▃ file a ▃▃▃▃▃▃▃▃▃▃▃▃
				# ▍line: file a 的內容
				# ▍▃▃ file b ▃▃▃▃▃▃▃▃▃▃▃▃
				# ▍line: file b 的內容
				# ▍▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃▃
				# 這一行也是大家都有的
				
				print OUT "\n■ 差異\n";
				print OUT $orig_text1[$okline1] if($okline1 >= 0);	# 若第一行就有差異, 就不能印第一行
				print_file_between_line($file1, \@orig_text1, $okline1, $index1);
				print_file_between_line($file2, \@orig_text2, $okline2, $index2);
				print OUT "▍" . "▃" x 39 . "\n";
				print OUT $orig_text1[$index1];
				
			}
			
			$okline1 = $index1;
			$okline2 = $index2;
			$index1++;
			$index2++;
		}
		else
		{
			# 發現差異, 所以 B 檔指標向下移, 若移動超過 $skipline , 則換成 A 檔指標下移, 
			# 若 A 檔也超過 $skipline , 就宣告差異太大, 結束比對.
			
			$index2++;
			
			if(($index2 > $okline2 + $skipline) or ($index2 > $#text2))	# 超過差異限制或超過檔案大小
			{
				$index1++;
				$index2 = $okline2 + 1;
				
				# A 檔也超過了差異限制
				if($index1 > $okline1 + $skipline)
				{
					$index1 = $okline1 + 1;
					$index2 = $okline2 + 1;
					last;
				}
			}
		}
	}
	
	# 判斷比對是否結束, 若有一檔還沒結束, 就要印出剩下的資料
	
	if( ($okline1 < $#text1) or ($okline2 < $#text2) )
	{
		print OUT "\n■ 比對中止，檔案末結束\n";
		print OUT $orig_text1[$okline1];
		
		# 判斷一下 A 檔剩下的檔案是否超過 $skipline 的範圍
		if($#text1 > $okline1 + $skipline)
		{
			# 超過 $skipline 的範圍, 只要再印 $skipline 的行數即可
			# 因為只要印出 $okline1 之後的 $skipline 行, 所以要用 $okline1 + $skipline + 1 的位置,才會印出 $okline1 + 1 那一行
			print_file_between_line($file1, \@orig_text1, $okline1, $okline1 + $skipline + 1);
			print OUT "▍.........【$file1 還沒結束, 比對已中止！】\n";
		}
		else
		{
			# 沒超過 $skipline 的範圍, 全印了
			print_file_between_line($file1, \@orig_text1, $okline1, $#text1 + 1);
			print OUT "▍【$file1 已結束！】\n";
		}
		
		# 判斷一下 B 檔剩下的檔案是否超過 $skipline 的範圍
		if($#text2 > $okline2 + $skipline)
		{
			# 超過 $skipline 的範圍, 只要再印 $skipline 的行數即可
			# 因為只要印出 $okline2 之後的 $skipline 行, 所以要用 $okline2 + $skipline + 1 的位置,才會印出 $okline2 + 1 那一行
			print_file_between_line($file2, \@orig_text2, $okline2, $okline2 + $skipline + 1);
			print OUT "▍.........【$file2 還沒結束, 比對已中止！】\n";
		}
		else
		{
			# 沒超過 $skipline 的範圍, 全印了
			print_file_between_line($file2, \@orig_text2, $okline2, $#text2 + 1);
			print OUT "▍【$file2 已結束！】\n";
		}
		print OUT "▍" . "▃" x 39 . "\n";
	}
	else
	{
		print OUT "\n■ 比對完畢！\n";
	}
}

############################################################
# 印出某一檔的 x 行到 y 行 (不包括 x 及 y 二行)
############################################################

sub print_file_between_line
{
	my $file = shift;
	my $text = shift;
	my $okline = shift;
	my $index = shift;
	
	print OUT "▍▃（$file）";
	print OUT "▃" x (36 - length($file) /2) . "\n";
	for(my $i = $okline + 1; $i < $index; $i++)
	{
		my $linenum = sprintf("%06d", $i+1);
		print OUT "▍$linenum : " . $text->[$i];
	}
}

############################################################
# 將檔案忽略的內容處理後, 存到 @text 陣列中
# 例如原始資料是
# ABCDEFG
# 忽略資料是 BE，則該行會變成
# ACDFG
############################################################

sub	do_skip
{
	my $text_a = shift;
	my $text_b = shift;
	my $skip = "[" . "\Q$opt_skip\E" . "]";	# 若要忽略 ABC , 則要處理 =~ s/[ABC]//; 因此要加 [ ] 中括號.

	for(my $i=0; $i<=$#$text_a; $i++)
	{
		$text_b->[$i] = $text_a->[$i];
		
		# 處理 $opt_skip_item 的項目
		# 目前有
		# a (a-z) : 忽略小寫英文字母 a-z
		# A (A-Z) : 忽略大寫英文字母 A-Z
		# d (digit) : 忽略數字 0-9
		# h (head) : 忽略行首 T01n0001_p0001a01║
		# p (punctuation) : 忽略全型標點，。、；：！？．—…「」『』（）《》〈〉“”
		# s (space) : 忽略半型空格
		# S (Space) : 忽略全部空格 (包含半型空格, 全型空格及 tab )
		# t (tag) : 忽略 <...> 角括號所包含的範圍
		
		if($opt_skip_item =~ /a/)
		{
			$text_b->[$i] =~ s/[a-z]//g;
		}
		if($opt_skip_item =~ /A/)
		{
			$text_b->[$i] =~ s/[A-Z]//g;
		}
		if($opt_skip_item =~ /d/)
		{
			$text_b->[$i] =~ s/\d//g;
		}
		if($opt_skip_item =~ /h/)
		{
			$text_b->[$i] =~ s/^.*?║//;
		}
		if($opt_skip_item =~ /p/)
		{
			$text_b->[$i] =~ s/[，。、；：！？．—…「」『』（）《》〈〉“”]//g;
		}
		if($opt_skip_item =~ /s/)
		{
			$text_b->[$i] =~ s/ //g;
		}
		if($opt_skip_item =~ /S/)
		{
			$text_b->[$i] =~ s/\s//g;
			$text_b->[$i] =~ s/　//g;
		}
		if($opt_skip_item =~ /t/)
		{
			$text_b->[$i] =~ s/<.*?>//g;
		}

		# 處理忽略的文字
		
		if($opt_skip ne "")
		{
			$text_b->[$i] =~ s/${skip}//g;
		}
	}
}

############################################################
# 將 utf8 編碼的文字轉成 big5 編碼
############################################################

sub tobig5
{
	my $utf8 = shift;
	return encode("big5", $utf8);
}

############################################################
# 印出說明
# 印出本檔最前面的內容, 直到遇到 use
############################################################

sub print_help
{
	open IN, "<:utf8", $0;
	while(<IN>)
	{
		last if(/^use /);
		print tobig5($_);
	}
}

############################################################
# End
############################################################