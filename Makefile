install-all:
	jag scan -t 4000ms -o short --list | xargs -n1 jag container install rudelblinken main.toit -d

uninstall-all:
	jag scan -t 4000ms -o short --list | xargs -n1 jag container uninstall rudelblinken -d

run-all:
	jag scan -t 4000ms -o short --list | xargs -n1 jag run main.toit -d

start-ap:
	sudo create_ap $$(ip link | grep -Po '^[0-9]+: [^ :]+' | grep -Po 'w[^ ]+$$' ) $$(ip route get 1.1.1.1 | grep -Po '(?<=(dev ))(\S+)')  'rudelctrl' '22po7gl334ai' --freq-band 2.4