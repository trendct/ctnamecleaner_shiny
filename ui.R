shinyUI(pageWithSidebar(
  
  headerPanel(
    list(HTML('<a href="http://www.trendct.org"><img src="trend-336x84.png" height="20"/></a>'), "CTNamecleaner"),
    windowTitle="CTNamecleaner"
  ),
  
  
  sidebarPanel(
    
    #Provide a dialogue to upload a file
    fileInput('datafile', 'Choose CSV file',
              accept=c('text/csv', 'text/comma-separated-values,text/plain')),
    #Define some dynamic UI elements - these will be lists containing file column names
    uiOutput("fromCol"),
    #We don't want the geocoder firing until we're ready...
    actionButton("getgeo", "Clean names"),
    downloadButton('downloadData', 'Download')
    
  ),
  mainPanel(
    includeMarkdown("readme.md"),
    #tableOutput("filetable"),
    h3(textOutput("caption")),
    tableOutput("geotable")
  )
))
