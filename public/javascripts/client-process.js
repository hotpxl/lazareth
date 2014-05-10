var a;
$.getJSON('/api/data', function(data) {
  a = data.data;
});

// Load the Visualization API and the piechart package.
google.load('visualization', '1.0', {'packages':['corechart']});

// Set a callback to run when the Google Visualization API is loaded.
google.setOnLoadCallback(drawChart);

// Callback that creates and populates a data table,
// instantiates the pie chart, passes in the data and
// draws it.
function drawChart() {

  // Create the data table.
  var data = google.visualization.arrayToDataTable(a);

  // Set chart options
  var options = {
    'title':'How Much Shit I Ate Last Night',
    height: 500,
    series: {
      1: {
       targetAxisIndex: 1
      }
    },
    vAxes: {
      1: {
        title: 'Return'
      }
    }
  };

  // Instantiate and draw our chart, passing in some options.
  var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
  chart.draw(data, options);
}

