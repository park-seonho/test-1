#!/bin/bash
if [ -z "$1" ]; then
	echo "usage: ./2025_OSS_Project1.sh file"
	exit 1
fi
filename=$1
echo "************OSS1 - Project1************"
echo "StudentID : 12223546"
echo "Name : Seonho Park"
echo "************************************"
echo

search_player_stats() {
	echo -n "Enter a player name to search: "
	read player_name
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
	Age=$(tail -n +2 "$filename" | awk -F, -v tab=$teamabb '$4 == tab {total += $3; count++ } END { printf "%.1f", total/count }')
	thr=$(tail -n +2 "$filename" | awk -F, -v tab=$teamabb '$4 == tab {total += $14 } END { print total }')
	RBI=$(tail -n +2 "$filename" | awk -F, -v tab=$teamabb '$4 == tab {total += $15 } END { print total }')
	echo "Team stats for $teamabb:"
	echo "Average age: $Age"
	echo "Total home runs: $thr"
	echo "Total RBI: $RBI"
}

compare_players() {
	echo "Compare players by age groups:"
	echo "1. Group A (Age < 25)"
	echo "2. Group B (Age 25-30)"
	echo "3. Group C (Age > 30)"
	echo -n "Select age group (1-3): "
	read group
}

search_specific_players() {
	echo "Find players with specific criteria"
	echo -n "Minimum home runs: "
	read minhr
	echo -n "Minimum batting average (e.g., 0.280): "
	read minbaav
}

generate_report() {
	echo "Generate a formatted player report for which team?"
	echo -n "Enter team abbreviation (e.g., NYY, LAD, BOS): "
	read teamabb
}


while true; do
	echo "[MENU]"
	echo "1.Search player stats by name in MLB data"
	echo "2.List top 5 players by SLG value"
	echo "3.Analyze the team stats - average age and toatl home runs"
	echo "4.Compare players in different age groups"
	echo "5.Search the players who meet specific statistical conditions"
	echo "6.Generate a performance report (formatted data)"
	echo "7.quit"
	echo -n "Enter your COMMAND (1-7) : "
	read command
	echo

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
			echo "exit the program"
			break
			;;
		*)
			echo "wrong Command. type 1-7"
			;;
	esac
done
