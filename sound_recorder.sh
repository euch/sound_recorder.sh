#!/bin/sh
WORK_DIR="/tmp"
REC_FORMAT="raw"
ENC_FORMAT="mp3"
ENCODER=""
ENCODER_OPTS=""
SAVE_DIR="/tmp/saved"
SAVE_RAW="yes"
SAVE_ENC="yes"
LOG=""
ERR_LOG=""

function __echo_hint__ {
	# Вывод подсказки по использованию программы
	echo -e "\nUsage:"
	echo "./Guitar_recorder.sh --record"
	echo "./Guitar_recorder.sh --id [ID] [OPTION]"
	echo -e "\nTry './Guitar_recorder.sh' --help for more information"
}
function __echo_help__ {
	# Вывод полной справки по использованию программы
	echo -e "\nUsage:"
	echo    "./Guitar_recorder.sh --record"
	echo    "./Guitar_recorder.sh --id [ID] [OPTION]"

	echo -e "\n\nApplication Options:"
	echo -e "--help                  display this help and exit\n"
	echo -e "--record                record signal from Mic IN\n"
	echo    "--id [ID] --play        play record by ID"
	echo 	"--if [ID] --info        display time and date of rec. start and file size"
	echo    "--id [ID] --encode      filter and encode record by ID"
	echo    "--id [ID] --save        save finished record by ID"
	echo -e "--id [ID] --delete      delete record by ID\n"
	echo    "--log                   display log"
	echo    "--error-log             display error log"
}
function __record__ {
	echo -e "Recording\n Press Ctrl-C to stop"
	ID=`date +%s`
	echo "`date`  ::  $ID"
	echo -e "\nRecord ID: $ID\n"
	arecord -t $REC_FORMAT -D hw -f S16_LE -c2 -r44100 $WORK_DIR/$ID.$REC_FORMAT
}
function __play__ {
	# Воспроизведение записи
	if [ -f $WORK_DIR/$ID.$REC_FORMAT ]; then
		echo "Playing: record #$ID"
		echo "Press Ctrl-C to stop"
		aplay -t $REC_FORMAT -f S16_LE -c2 -r44100 $WORK_DIR/$ID.$REC_FORMAT
	else
		echo "Record #$ID is not exist"
	fi
}
function __info__ {
	utime(){ awk -v d=$ID 'BEGIN{print strftime("%a %b %d %H:%M:%S %Y", d)}'; }
	if [ -f $WORK_DIR/$ID.$REC_FORMAT ]; then
		utime
		du -h $WORK_DIR/$ID.$REC_FORMAT
	else
		echo "Record #$ID is not exist"
		echo "It could be written on `utime`"
	fi
}
function __encode__ {
	# Сжатие и обработка записи
	if [ -f $WORK_DIR/$ID.$REC_FORMAT ]; then
		echo "Encoding to $ENC_FORMAT..."
		sleep 5 # Заглушка
		echo -e "Done\nFile location: $WORK_DIR/$ID.$ENC_FORMAT"
	else
		echo "Record #$ID is not exist"
	fi
}
function __save__ {
	# Сохранение записи в заданный каталог
	mkdir -p $SAVE_DIR
	if test $SAVE_RAW = "yes" ; then
		if [ -f $WORK_DIR/$ID.$REC_FORMAT ] ; then
			mv $WORK_DIR/$ID.$REC_FORMAT $SAVE_DIR/$ID.$REC_FORMAT
			-e echo "\nOrginal ($REC_FORMAT)record succesfully saved in $SAVE_DIR/$ID.$REC_FORMAT"
		else
			echo -e "\nRecord #$ID is not exist"
		fi
	fi

	if test $SAVE_ENC = "yes" ; then
		if [ -f $WORK_DIR/$ID.$ENC_FORMAT ]; then
			mv $WORK_DIR/$ID.$ENC_FORMAT $SAVE_DIR/$ID.$ENC_FORMAT
			echo -e "\nRecord encoded to $ENC_FORMAT succesfully saved in $SAVE_DIR/$ID.$ENC_FORMAT"
		else
			echo -e "\nRecord #$ID encoded to $ENC_FORMAT is not exist"
			echo "Try "./Guitar_recorder --id [ID] --encode" first"
		fi
	fi
}
function __delete__ {
	# Удаление
	if [ -f $WORK_DIR/$ID.$REC_FORMAT ]; then
		rm -f $WORK_DIR/$ID.$REC_FORMAT
		echo "Record $ID deleted"
	else
		echo "Record #$ID is not exist"
	fi
	
}
function __show_log__ {
	less $LOG
}
function __show_error_log {
	less $ERR_LOG
}


# Обработка аргументов командной строки
if [ $# != 0 ]; then
	FLAG="$1"
	case "$FLAG" in
		--help)
			__echo_help__
		;;
		--record)
			__record__
		;;
		--id)
			# Параметры для работы над записью через её ID
			if [ $# -gt 1 ]; then
				ID="$2"
				ACTION="$3"
				case "$ACTION" in
					--play)
						__play__
					;;
					--info)
						__info__
					;;
					--encode)
						__encode__
					;;
					--save)
						__save__
					;;
					--delete)
						__delete__
					;;
					*)
						echo "Unrecognized flag or argument: '$ACTION'"
						__echo_hint__
					;;
				esac
			else
				echo "You supplied no argument for the --id flag: '$ID'"
				__echo_hint__
			fi
		;;
		*)
			echo "Unrecognized flag or argument: '$FLAG'"
			__echo_hint__
		;;
	esac
else
	echo "Missing flag or argument"
	__echo_hint__
fi

