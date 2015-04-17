jQuery ->
  $('#money_health').highcharts
    chart: type: 'bar'
    title: text: 'Money Health'
    xAxis: categories: ['Invoiced', 'Received', 'Owed']
    yAxis: title: text: 'Dollars'
    series: [
      {
        name: 'Amount'
        data: [1, 4, 7]
      }
    ]
  return
