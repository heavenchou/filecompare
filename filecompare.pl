######################################################################################
# 程式說明：將指定目錄中的檔案合成一個大檔                        by heaven 2013/06/12
# 使用方法：
#       perl connect.pl -s 來源目錄及檔案種類 -o 輸出結果的檔案 [-c -v -d]
# 參數說明：
#       -s 來源目錄，要包含檔案的種類模式，例如 -s c:\temp\*.txt
#       -o 結果檔案，例如 -o c:\out.txt
#       -c 切除行首，如果行首是 T01n0001_a01║ 這種型格，皆一律移除
#       -v 檔案前十行若有 V1.0 這種版本格式，一律換成 Vv.v，以方便比對
#       -d 檔案前十行若有 2013/06/11 這種日期格式，一律換成 yyyy/mm/dd，以方便比對
# 範例：
#       perl connect.pl -s c:\release\bm\normal\T01\*.txt -o c:\temp\T01.txt -c -v -d
######################################################################################

#use utf8;
use Encode;
use strict;
use autodie;
use Getopt::Std;
use vars qw($opt_s $opt_o $opt_c $opt_v $opt_d);		# 如果有使用 use strict; , 本行就要加上去

############################################################
# 變數
############################################################

my $infile1 = "a.txt";
my $infile2 = "b.txt";
my $outfile = "c.txt";

my $skipline = 10; # 差異超過此行就放棄

############################################################
# 檢查參數
############################################################

getopts('s:o:cvd');

print "【檔案比對程式】\n";

if($opt_s eq "")
{
	#print "錯誤：沒有使用 -s 參數\n";
	#exit;
}
if($opt_o eq "")
{
	#print "錯誤：沒有使用 -o 參數\n";
	#exit;
}

print "檔案一 : $opt_s\n";
print "檔案二 : $opt_o\n";

############################################################
# 主程式
############################################################

open OUT, ">:utf8", $outfile;

compare($infile1 , $infile2);

print "處理完畢.\n\n";
<>;

############################################################
# 檔案比對
############################################################

sub compare()
{
	my $file1 = shift;
	my $file2 = shift;
	
	my @text1 = ();	# 儲存檔案的內容
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
	while(<IN>)	{ push @text1, $_; }
	close IN;
	
	# 讀取第二個檔案
	open IN, "<:utf8", $file2;
	while(<IN>)	{ push @text2, $_; }
	close IN;
	
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
				print_file_between_line($file1, \@text1, $okline1, $index1);
				print_file_between_line($file2, \@text2, $okline2, $index2);
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
	
	# 判斷比對是否結束
	
	if($okline1 < $#text1)
	{
		print OUT "\n\n$file1\n";
		print OUT $text1[$okline1];
		print OUT "================================\n";
		print OUT $text1[$okline1+1];
		print OUT "........\n";
		print OUT "$file1 還沒結束, 比對已中止\n";
	}
	if($okline2 < $#text2)
	{
		print OUT $text2[$okline2];
		print OUT "================================\n";
		print OUT $text2[$okline2+1];
		print OUT "........\n";
		print OUT "$file2 還沒結束, 比對已中止\n";
	}
}

############################################################
# 印出某一檔的 x 行到 y 行 (要包括 x 及 y 二行)
############################################################

sub print_file_between_line
{
	my $file = shift;
	my $text = shift;
	my $okline = shift;
	my $index = shift;
	
	print OUT "\n\n$file\n";
	print OUT $text->[$okline];
	print OUT "================================\n";
	for(my $i = $okline + 1; $i < $index; $i++)
	{
		print OUT $text->[$i];
	}
	print OUT "================================\n";
	print OUT $text->[$index];
}

############################################################
# End
############################################################