@call \cbwork\bin\perl516.bat run
rem ===============================================================================================
rem �H�W���]�w perl 5.16 ����������
rem �{�������G                                              by heaven 2013/06/13
rem       �ɮפ��A�� utf8 �s�X�A�H�u��v�������A�L�k�B�z�榡���P���ɮסC
rem �ϥΤ�k�G
rem       perl filecompare.pl -f1 �ɮ�1 -f2 �ɮ�2 -o ��ﵲ�G�� [-h]
rem �Ѽƻ����G
rem       -f1 �n��諸�ɮ�1
rem       -f2 �n��諸�ɮ�2
rem       -o ��ﵲ�G
rem       -h �C�X����
rem �d�ҡG
rem        perl filecompare.pl -h
rem        perl filecompare.pl -f1 a.txt -f2 b.txt -o c.txt
rem        perl filecompare.pl -f1=a.txt -f2=b.txt -o=c.txt
rem ===============================================================================================
echo on

perl filecompare.pl -f1 a.txt -f2 b.txt -o c.txt