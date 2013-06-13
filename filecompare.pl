######################################################################################
# �{�������G�N���w�ؿ������ɮצX���@�Ӥj��                        by heaven 2013/06/12
# �ϥΤ�k�G
#       perl connect.pl -s �ӷ��ؿ����ɮ׺��� -o ��X���G���ɮ� [-c -v -d]
# �Ѽƻ����G
#       -s �ӷ��ؿ��A�n�]�t�ɮת������Ҧ��A�Ҧp -s c:\temp\*.txt
#       -o ���G�ɮסA�Ҧp -o c:\out.txt
#       -c �����歺�A�p�G�歺�O T01n0001_a01�� �o�ث���A�Ҥ@�߲���
#       -v �ɮ׫e�Q��Y�� V1.0 �o�ت����榡�A�@�ߴ��� Vv.v�A�H��K���
#       -d �ɮ׫e�Q��Y�� 2013/06/11 �o�ؤ���榡�A�@�ߴ��� yyyy/mm/dd�A�H��K���
# �d�ҡG
#       perl connect.pl -s c:\release\bm\normal\T01\*.txt -o c:\temp\T01.txt -c -v -d
######################################################################################

#use utf8;
use Encode;
use strict;
use autodie;
use Getopt::Std;
use vars qw($opt_s $opt_o $opt_c $opt_v $opt_d);		# �p�G���ϥ� use strict; , ����N�n�[�W�h

############################################################
# �ܼ�
############################################################

my $infile1 = "a.txt";
my $infile2 = "b.txt";
my $outfile = "c.txt";

my $skipline = 10; # �t���W�L����N���

############################################################
# �ˬd�Ѽ�
############################################################

getopts('s:o:cvd');

print "�i�ɮפ��{���j\n";

if($opt_s eq "")
{
	#print "���~�G�S���ϥ� -s �Ѽ�\n";
	#exit;
}
if($opt_o eq "")
{
	#print "���~�G�S���ϥ� -o �Ѽ�\n";
	#exit;
}

print "�ɮפ@ : $opt_s\n";
print "�ɮפG : $opt_o\n";

############################################################
# �D�{��
############################################################

open OUT, ">:utf8", $outfile;

compare($infile1 , $infile2);

print "�B�z����.\n\n";
<>;

############################################################
# �ɮפ��
############################################################

sub compare()
{
	my $file1 = shift;
	my $file2 = shift;
	
	my @text1 = ();	# �x�s�ɮת����e
	my @text2 = ();
	
	my $okline1 = -1;	# �b�峹������ƫ��СA��ܥثe�G�̤��e�ۦP�����
	my $okline2 = -1;
	
	my $index1 = 0;	# �b�峹������ƫ��СA��ܥثe���n�B�z����ơC
	my $index2 = 0;


    # ���Хܽd
    #
	# �ɮפ@              �ɮפG
	# AAA                 AAA 
	# BBB $okline1=2      BBB $okline2=2
	# CCC $index1=3       XXX
	# DDD                 DDD $index2=4
	# EEE                 EEE
	#
	# �쥻 $index2=3 , ���P $index1=3 ���e���P, �ҥH $index2=4 �V�U���F�@��

	
	# Ū���Ĥ@���ɮ�
	open IN, "<:utf8", $file1;
	while(<IN>)	{ push @text1, $_; }
	close IN;
	
	# Ū���ĤG���ɮ�
	open IN, "<:utf8", $file2;
	while(<IN>)	{ push @text2, $_; }
	close IN;
	
	############################
	# �}�l���
	############################
	
	# ����޿� :
	# �Ĥ@��(A��)�Ĥ@��P�ĤG��(B��)�Ĥ@����.
	# �Y�ۦP�N�~��
	# �Y���P, A �ɲĤ@���� B �ɲĤG��, �Y���P�� B �ɲĤT��, ����W�L 10 ��N���.
	# ���� A �ɲĤG���� B �ɲĤ@��, �Y�P�� B �ɲĤG��, ����W�L 10 ��N���.
	# ���� A �ɲĤT��.....
	# �Y A �ɲ� 10 ��̵M�S����� B �ɪ��Y�@��, �N�������. (���B 10 ��N�O $skipline �ܼ�)
	
	while( ($index1 <= $#text1) and ($index2 <= $#text2) )
	{
		if($text1[$index1] eq $text2[$index2])
		{
			# �o�G��۵�, �n�⤧�e���۵����U��L�X��
			# �Ҧp���e A, B �ɬO�b 0, 0 ��۵�.
			# �{�b�O�b 1, 3 ��۵�, �ҥH A �ɤ��ΦL, B �ɭn�L�X 1, 2 �G��.
			
			# �o�G��ۦP, �b���e�Y�����ۦP���t��, �N�n�L�X��
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
			# �o�{�t��, �ҥH B �ɫ��ЦV�U��, �Y���ʶW�L $skipline , �h���� A �ɫ��ФU��, 
			# �Y A �ɤ]�W�L $skipline , �N�ŧi�t���Ӥj, �������.
			
			$index2++;
			
			if(($index2 > $okline2 + $skipline) or ($index2 > $#text2))	# �W�L�t������ζW�L�ɮפj�p
			{
				$index1++;
				$index2 = $okline2 + 1;
				
				# A �ɤ]�W�L�F�t������
				if($index1 > $okline1 + $skipline)
				{
					$index1 = $okline1 + 1;
					$index2 = $okline2 + 1;
					last;
				}
			}
		}
	}
	
	# �P�_���O�_����
	
	if($okline1 < $#text1)
	{
		print OUT "\n\n$file1\n";
		print OUT $text1[$okline1];
		print OUT "================================\n";
		print OUT $text1[$okline1+1];
		print OUT "........\n";
		print OUT "$file1 �٨S����, ���w����\n";
	}
	if($okline2 < $#text2)
	{
		print OUT $text2[$okline2];
		print OUT "================================\n";
		print OUT $text2[$okline2+1];
		print OUT "........\n";
		print OUT "$file2 �٨S����, ���w����\n";
	}
}

############################################################
# �L�X�Y�@�ɪ� x ��� y �� (�n�]�A x �� y �G��)
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