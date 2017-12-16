#!/bin/sh
# -*- coding: utf-8 -*-
#
#  CCScanDir.sh
#
#  Created by CC on 2017/12/16.
#  Copyright 2017 youhua deng (deng you hua | CC) <ccworld1000@gmail.com>
#  https://github.com/ccworld1000/CCScanDir
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#
#

xibCount=0
hCount=0
mCount=0
mmCount=0
stringsCount=0
totalCount=0
protoCount=0
storyboardCount=0
otherCount=0

function CCScanDir () {
	OLDIFS=$IFS
	IFS=$'\n'

	for e in `ls $1`
	do
		dir_or_file="$1/$e"

		if [[ $dir_or_file =~ /build/ ]] || [[ $dir_or_file =~ /Pods/ ]] || [[ $dir_or_file =~ /Images.xcassets/ ]] || [[ $dir_or_file =~ .xcworkspace/ ]] || [[ $dir_or_file =~ .xcodeproj/ ]] || [[ $dir_or_file =~ /Charts/ ]] || [[ $dir_or_file =~ /ThirdParty/ ]]
		then
			#echo "ignore $dir_or_file"
			[[ 1 == 1 ]];
		else
			if [ -d $dir_or_file ]
				then
					CCScanDir $dir_or_file
				else
					echo "$dir_or_file"

					if [[ $dir_or_file =~ .xib$ ]]; then
						((xibCount = xibCount + 1))
					elif [[ $dir_or_file =~ .h$ ]]; then
						((hCount = hCount + 1))
					elif [[ $dir_or_file =~ .m$ ]]; then
						((mCount = mCount + 1))
					elif [[ $dir_or_file =~ .strings$ ]]; then
						((stringsCount = stringsCount + 1))
					elif [[ $dir_or_file =~ .proto$ ]]; then
						((protoCount = protoCount + 1))
					elif [[ $dir_or_file =~ .storyboard$ ]]; then
						((storyboardCount = storyboardCount + 1))
					fi

					((totalCount = totalCount + 1))
			fi
		fi

	done

	IFS=$OLDIFS
}

function genPie() {
	# echo "age,population" > data.csv
	# echo "totalCount , $totalCount" >> data.csv
	# echo "xibCount , $xibCount" >> data.csv
	# echo "hCount , $hCount" >> data.csv
	# echo "mCount , $mCount" >> data.csv
	# echo "stringsCount , $stringsCount" >> data.csv
	# echo "protoCount , $protoCount" >> data.csv
	# echo "storyboardCount , $storyboardCount" >> data.csv

	((otherCount = totalCount - xibCount - hCount - mCount - stringsCount - protoCount - storyboardCount ))
	titles=("xib" "heaer" "m" "strings" "proto" "storyboard" "other")

	values=()
	values[0]=$xibCount
	values[1]=$hCount
	values[2]=$mCount
	values[3]=$stringsCount
	values[4]=$protoCount
	values[5]=$storyboardCount
	values[6]=$otherCount

	count=${#titles[@]}

	html='CCScanDir.html'
	echo "
			<!DOCTYPE html>
			<html>
			  <head>
			      <meta charset='utf-8'>
						‍<meta name='generator' content='CCScanDir (https://github.com/ccworld1000/CCScanDir)' />
			      <title>CCScanDir</title>
			      <script src='js/echarts.js'></script>
			  </head>
			<body>
			<div id='CCScanDir' style='width: 600px;height:600px;'></div>
			<h1>CCScanDir</h1>
			<h2><a href='mailto:ccworld1000@gmail.com'>feedback</a></h2>
			<script type='text/javascript'>
			  function genData(count) {
			      var legendData = [];
			      var seriesData = [];
						" > "$html"

			step=0
			for name in ${titles[@]};
			do
				a=${values[$step]}
				percentage=$(printf "%.0f%%" $((a * 100 / totalCount)))
				displayTitle="'$name [$a file] $percentage'"
				echo "
						legendData.push($displayTitle);
						seriesData.push({ name: $displayTitle, value: ${values[$step]}});

						" >> "$html"
				((step = step + 1))
			done

echo "			return {
			          legendData: legendData,
			          seriesData: seriesData
			      };
			  }

			  var myChart = echarts.init(document.getElementById('CCScanDir'));
			  var data = genData($count);

			  option = {
			      title : {
			          text: '文件数量统计',
			          subtext: 'CCScanDir (https://github.com/ccworld1000/CCScanDir)',
			          x:'center'
			      },
			      tooltip : {
			          trigger: 'item',
			          formatter: '{a} <br/>{b} : {c} ({d}%)'
			      },
			      legend: {
			          type: 'scroll',
			          orient: 'vertical',
			          right: 10,
			          top: 20,
			          bottom: 20,
			          data: data.legendData
			      },
			      series : [
			          {
			              name: '文件类型名称',
			              type: 'pie',
			              radius : '55%',
			              center: ['40%', '50%'],
			              data: data.seriesData,
			              itemStyle: {
			                  emphasis: {
			                      shadowBlur: 10,
			                      shadowOffsetX: 0,
			                      shadowColor: 'rgba(0, 0, 0, 0.5)'
			                  }
			              }
			          }
			      ]
			  };

			  myChart.setOption(option);
			</script>
			</body>
			</html>
	" >> "$html"
}

if (($# > 0)) && [ -d $1 ]; then
		CCScanDir $1
fi
