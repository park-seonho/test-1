#!/bin/bash
if [ -z "$1" ]; then
	echo "usage: ./2025_OSS_Project1.sh file"
	exit 1
fi
if [ ! -e "$1" ]; then
	echo "no file detected"
	exit 1
fi
filename=$1
echo "************OSS1 - Project1************"
echo "*       StudentID : 12223546      *"
echo "*       Name : Seonho Park        *"
echo "************************************"
echo

search_player_stats() {
	echo -n "Enter a player name to search: "
	read player_name
	echo
	results=$(grep "$player_name" "$filename")
	SDP=$(echo "$results" | sed 's/^\([^,]*,\)\{3\}\([^,]*\).*/\2/')
	Age=$(echo "$results" | sed 's/^\([^,]*,\)\{2\}\([^,]*\).*/\2/')
	WAR=$(echo "$results" | sed 's/^\([^,]*,\)\{5\}\([^,]*\).*/\2/')
	HR=$(echo "$results" | sed 's/^\([^,]*,\)\{13\}\([^,]*\).*/\2/')
	BA=$(echo "$results" | sed 's/^\([^,]*,\)\{19\}\([^,]*\).*/\2/')

	echo "Player stats for \"$player_name\":"
	echo "Player: $player_name, Team: $SDP, Age: $Age, WAR: $WAR, HR: $HR, BA: $BA"
	echo
}

list_top_players() {
	echo -n "Do you want to see the top 5 players by SLG? (y/n) : "
	read answer
	case $answer in
		y)
			echo
			;;
		n)
			return
			;;
		*)
			echo "type correct answer"
			list_top_players
			;;
	esac
	sort=$(tail -n +2 "$filename" |awk -F',' '$8 >= 502' | sort -t ',' -k22 -nr | head -n 5)

	echo "***Top 5 Players by SLG***"
	echo "$sort" | awk -F',' '{
	printf "%d. %s (Team: %s) - SLG: %s, HR: %s, RBI: %s\n", NR, $2, $4, $22, $14, $15}'
	echo
}

analyze_team_stats() {
	echo -n "Enter team abbreviation (e.g., NYY, LAD, BOS): "
	read teamabb
	echo
	Age=$(tail -n +2 "$filename" | awk -F, -v tab=$teamabb '$4 == tab {total += $3; count++ } END { printf "%.1f", total/count }')
	thr=$(tail -n +2 "$filename" | awk -F, -v tab=$teamabb '$4 == tab {total += $14 } END { print total }')
	RBI=$(tail -n +2 "$filename" | awk -F, -v tab=$teamabb '$4 == tab {total += $15 } END { print total }')
	echo "Team stats for $teamabb:"
	echo "Average age: $Age"
	echo "Total home runs: $thr"
	echo "Total RBI: $RBI"
	echo
}

compare_players() {
	echo
	echo "Top 5 by SLG in Group C (Age > 30):"
	echo "Compare players by age groups:"
	echo "1. Group A (Age < 25)"
	echo "2. Group B (Age 25-30)"
	echo "3. Group C (Age > 30)"
	echo -n "Select age group (1-3): "
	read group
	echo
	case $group in
		1)
			sort=$(tail -n +2 "$filename" |awk -F, '$8 >= 502' |awk -F',' '$3 < 25' | sort -t ',' -k22 -nr | head -n 5)
			gr2="A (Age < 25)"
			;;
		2)
			sort=$(tail -n +2 "$filename" |awk -F, '$8 >= 502' |awk -F',' '($3 >= 25)&&($3 <= 30)' | sort -t ',' -k22 -nr | head -n 5)
			gr2="B (Age 25-30)"
			;;
		3)
			sort=$(tail -n +2 "$filename" |awk -F, '$8 >= 502' |awk -F',' '$3 > 30' | sort -t ',' -k22 -nr | head -n 5)
			gr2="C (Age > 30)"
			;;
		*)
			echo "choose wrong group"
			compare_players
	esac
	echo "Top 5 by SLG in Group $gr2:"
	echo "$sort" | awk -F',' '{
	printf "%s (%s) - Age: %s, SLG: %s, BA: %s, HR: %s\n", $2, $4, $3, $22, $20, $14}'
	echo
}

search_specific_players() {
	echo
	echo "Find players with specific criteria"
	echo -n "Minimum home runs: "
	read minhr
	echo -n "Minimum batting average (e.g., 0.280): "
	read minbaav
	sort=$(tail -n +2 "$filename" |awk -F, '$8 >= 502' |awk -F, -v minhr=$minhr -v minbaav=$minbaav '($14 >= minhr)&&($20 >= minbaav)' | sort -t ',' -k14,14nr)
	echo
	echo "Players with HR ≥ $minhr and BA ≥ $minbaav:"
	echo "$sort" | awk -F',' '{
        printf "%s (%s) - HR: %s, BA: %s, RBI: %s, SLG: %s\n", $2, $4, $14, $20, $15, $22}'
	echo

}

generate_report() {
	echo "Generate a formatted player report for which team?"
	echo -n "Enter team abbreviation (e.g., NYY, LAD, BOS): "
	read teamabb
	count=$(tail -n +2 "$filename" | awk -F, -v teamabb=$teamabb '{if ($4 == teamabb) c++} END { print c }')
	sort=$(tail -n +2 "$filename" | awk -F, -v teamabb=$teamabb '$4 == teamabb' | sort -t ',' -k14,14nr)
	echo
	echo "================== $teamabb PLAYER REPORT =================="
	echo -n "Date: "
	date +"%Y/%m/%d"
	echo "--------------------------------"
	echo -e "PLAYER     \t\tHR\tRBI\tAVG\tOBP\tOPS"
	echo "--------------------------------"
	echo -e "$sort" | awk -F, '{
	printf "%-20s \t%s \t%s \t%s \t%s \t%s\n", $2, $14, $15, $20, $21, $23}'
	echo "------------------"
	echo "TEAM TOTALS: $count players"
}


while true; do
	echo "[MENU]"
	echo "1.Search player stats by name in MLB data"
	echo "2.List top 5 players by SLG value"
	echo "3.Analyze the team stats - average age and total home runs"
	echo "4.Compare players in different age groups"
	echo "5.Search the players who meet specific statistical conditions"
	echo "6.Generate a performance report (formatted data)"
	echo "7.quit"
	echo -n "Enter your COMMAND (1-7) : "
	read command

	case $command in
		1)
			search_player_stats
			;;
		2)
			list_top_players
			;;
		3)
			analyze_team_stats
			;;
		4)
			compare_players
			;;
		5)
			search_specific_players
			;;
		6)
			generate_report
			;;
		7)
			echo "Have a good day!"
			break
			;;
		*)
			echo "wrong Command. type 1-7"
			;;
	esac
done
