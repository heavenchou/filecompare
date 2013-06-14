@call \cbwork\bin\perl516.bat run
rem ===============================================================================================
rem 以上先設定 perl 5.16 的執行環境
rem 程式說明：                                              by heaven 2013/06/13
rem       檔案比對，限 utf8 編碼，以「行」為比對單位，無法處理格式不同的檔案。
rem 使用方法：
rem       perl filecompare.pl -f1 檔案1 -f2 檔案2 -o 比對結果檔 [-h]
rem 參數說明：
rem       -f1 要比對的檔案1
rem       -f2 要比對的檔案2
rem       -o 比對結果
rem       -h 列出說明
rem 範例：
rem        perl filecompare.pl -h
rem        perl filecompare.pl -f1 a.txt -f2 b.txt -o c.txt
rem        perl filecompare.pl -f1=a.txt -f2=b.txt -o=c.txt
rem ===============================================================================================
echo on

perl filecompare.pl -f1 a.txt -f2 b.txt -o c.txt