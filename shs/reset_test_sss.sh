#!/bin/sh
ssFileName=NULL
ssCfgPath=/home/alass/shadowsocks
ssSrvBinFile=/usr/local/bin/ssserver

pick_ssFile() {
	currHour=`date +%H`
	fileFlag=`expr $currHour / 2 % 2`
	
	#�ýű�ÿ2Сʱ��1�Σ���������glow+0,glow+1��Ӧ�Ľ��̵�����
	if [ "$fileFlag" = "0" ]; then
		ssFileName=glow+0.json
	else
		ssFileName=glow+1.json
	fi
}

reset_ssPswd() {
	ssPassWord=`date +%s | sha256sum | base64 | head -c 12; echo`
	sed -i 's/password.*$/password":"'$ssPassWord'",/' $ssCfgPath/$ssFileName
}

start_ssServer() {
	logFileName=`echo $ssFileName | sed s/.json//g`
	cd $ssCfgPath
	nohup $ssSrvBinFile -c $ssFileName > logs/nohup_$logFileName.out 2>&1 < /dev/null &
	cd -
}

stop_ssServer() {
	ssServerPid=`ps aux | grep $ssFileName | grep -v grep | awk '{print $2}'`
	
	if [ "$ssServerPid" = "" ]; then
		echo no ss found
	elif [ $ssServerPid -gt 0 ]; then
		kill -9 $ssServerPid ;
	fi
}

send_mail() {
	# mailReceiver=$1
	# if [ -z $1 ]; then
		# echo please input mail receiver.
		# exit
	# fi
		
	mailContentFile=/tmp/chg_test_pswd_mail.txt
	
	echo "��ӭ����AlaSS�����˺ţ�����JSON������Ϣ��"										>  $mailContentFile
	echo ""																					>> $mailContentFile
	cat  $ssCfgPath/$ssFileName 															>> $mailContentFile
	echo ""																					>> $mailContentFile
	echo "�뾡����ԣ������˺�������2Сʱ��ʧЧ��"											>> $mailContentFile
	echo ""																					>> $mailContentFile
	echo "��Ӣ���գ�"																		>> $mailContentFile
	echo "���������� IP  <=> server"														>> $mailContentFile
	echo "�����������˿� <=> server_port"													>> $mailContentFile
	echo "��������       <=> password"														>> $mailContentFile
	echo "��������       <=> method"														>> $mailContentFile
	echo "���������˿�   <=> local_port"													>> $mailContentFile
	echo ""																					>> $mailContentFile
	echo "���÷����ɲο�ShadowSocks�ͻ���ʹ�ý̳�: http://www.alafafa.com/?p=89"			>> $mailContentFile
	echo "��������ShadowSocks��Windows�ͻ��ˣ�������Ⱥ:387477811����Ⱥ�����ļ�����"		>> $mailContentFile
	echo "��������֮����ͨ���Ա�����: http://item.taobao.com/item.htm?id=42743439161"		>> $mailContentFile
	
	#mail -s "AlaSS Test Account Info" 'lijj@asiainfo.com' 'lijiajun@gmail.com' 'yelijuns@gmail.com' < $mailContentFile
	cat $mailContentFile|mail -s "AlaSS Test Account Info" 'lijj@asiainfo.com' 'yelijuns@gmail.com'
}

main() {
	pick_ssFile;
	reset_ssPswd;
	stop_ssServer
	start_ssServer;
	send_mail;
}

main