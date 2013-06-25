'''
程式說明：檔案比對程式 filecompare.pl 的圖形界面。　　   by heaven 2013/06/25
注意事項：本程式要安裝 QtPy 4 (http://www.riverbankcomputing.co.uk/software/pyqt/download)
'''

import sys, os
from PyQt4 import QtGui, uic

class MyWindow(QtGui.QMainWindow):
	def __init__(self):
		super(MyWindow, self).__init__()
		uic.loadUi('filecompare.ui', self)
		self.obj_connect()	# 連結各物件的程式

	# 連結各物件的程式
	def obj_connect(self):
		self.btGetFile1.clicked.connect(self.GetFile1)
		self.btGetFile2.clicked.connect(self.GetFile2)
		self.btGetFile3.clicked.connect(self.GetFile3)
		self.btExit.clicked.connect(self.close)
		self.btRun.clicked.connect(self.ok_run)
		
	def GetFile1(self):
		str = QtGui.QFileDialog.getOpenFileName (self, "比對檔案1", ".", "*.*")
		self.edFileName1.setText(str)
		
	def GetFile2(self):
		str = QtGui.QFileDialog.getOpenFileName (self, "比對檔案2", ".", "*.*")
		self.edFileName2.setText(str)
		
	def GetFile3(self):
		str = QtGui.QFileDialog.getOpenFileName (self, "輸出檔案", ".", "*.*")
		self.edFileName3.setText(str)

	# 秀錯誤訊息
	def show_message(self, message):
		QtGui.QMessageBox.warning(self, "檔案比對", message, QtGui.QMessageBox.Ok)

	# 檢查參數, 看看檔名是否都輸入了
	def check_para(self):
		if(self.edFileName1.text() == ""):
			self.show_message('比對檔案一 欄位必須要輸入！')
			self.edFileName1.setFocus()
			return False
		if(self.edFileName2.text() == ""):
			self.show_message('比對檔案二 欄位必須要輸入！')
			self.edFileName2.setFocus()
			return False
		if(self.edFileName3.text() == ""):
			self.show_message('結果檔案 欄位必須要輸入！')
			self.edFileName3.setFocus()
			return False
		return True

	# 做出要執行的命令列
	def make_command(self):
		com = 'perl filecompare.pl -f1 ' + self.edFileName1.text()
		com += ' -f2 ' + self.edFileName2.text()
		com += ' -o ' + self.edFileName3.text()
		if(self.edSkipWord.text() != ""):
			# 設定忽略文字
			com += ' -skip ' + self.edSkipWord.text()
		if(self.edSkipRe.text() != ""):
			# 設定忽略正規式
			com += ' -skip_re ' + self.edSkipRe.text()
		
		skipitem = ''
		if(self.cbSkipItem_a.isChecked()): skipitem += 'a'
		if(self.cbSkipItem_A.isChecked()): skipitem += 'A'
		if(self.cbSkipItem_d.isChecked()): skipitem += 'd'
		if(self.cbSkipItem_h.isChecked()): skipitem += 'h'
		if(self.cbSkipItem_p.isChecked()): skipitem += 'p'
		if(self.cbSkipItem_s.isChecked()): skipitem += 's'
		if(self.cbSkipItem_S.isChecked()): skipitem += 'S'
		if(self.cbSkipItem_t.isChecked()): skipitem += 't'
		if(skipitem != ""):
			# 設定忽略的選項
			com += ' -skip_item ' + skipitem
		self.edRunCommand.setText(com)

	# 執行
	def ok_run(self):
		chkpara = self.check_para()					# 檢查一下檔名是否都有輸入
		if(chkpara == True):
			self.make_command()						# 產生命令列
			os.system(self.edRunCommand.text())		# 執行

##############################################
# 主程式
##############################################

if __name__ == '__main__':
	app = QtGui.QApplication(sys.argv)
	window = MyWindow()
	window.show()
	sys.exit(app.exec_())