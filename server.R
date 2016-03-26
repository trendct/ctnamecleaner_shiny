list.of.packages <- c("shiny", "ctnamecleaner")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages,function(x){library(x,character.only=TRUE)}) 

shinyServer(function(input, output) {
  
  #Handle the file upload
  filedata <- reactive({
    infile <- input$datafile
    if (is.null(infile)) {
      # User has not uploaded a file yet
      return(NULL)
    }
    read.csv(infile$datapath)
  })
  
  #Populate the list boxes in the UI with column names from the uploaded file  
  output$fromCol <- renderUI({
    df <-filedata()
    if (is.null(df)) return(NULL)
    
    items=names(df)
    names(items)=items
    selectInput("from", "Town names column",items)
  })
  
  #The geocoding bit... Isolate variables so we don't keep firing this...
  geodata <- reactive({
    if (input$getgeo == 0) return(NULL)
    df=filedata()
    if (is.null(df)) return(NULL)
    
    isolate({
      dummy=filedata()
      fr=input$from
      names(dummy)[names(dummy) == fr] <- 'Town'
      dummy <- ctnamecleaner(Town, dummy)
      dummy
    })
  })
  
  #Weave the goecoded data into the data frame we made from the CSV file
  geodata2 <- reactive({
    if (input$getgeo == 0) return(NULL)
    df=filedata()
    
    gf=geodata()
    #df=merge(df,gf,by.x=input$from,by.y='place')
    #merge(df,gf,by.x=input$to,by.y='place')
  })
  # 
  
  output$caption <- renderText({
    if (input$getgeo == 0) return("")
    #if (input$getgeo == 0) return(NULL)
    #output$caption <- paste("There were", sum(is.na(df$real.town.name)), "names we couldn't match.")
    
    df <- geodata2()
    
    nomatch <- sum(is.na(df$real.town.name))
    
    if (nomatch == 0) {
      print("Congrats, all town names were matched.")
    } else if (nomatch ==1) {
      print("There was 1 town name we could not match.")
    } else {
      paste("There were", nomatch, "names we couldn't match.")
    }
    
    
  })
  
  
  
  #Preview the geocoded data
  output$geotable <- renderTable({
    if (input$getgeo == 0) return(NULL)
    geodata2()
    
    #p("I dunno")
  })
  
  output$downloadData <- downloadHandler(
    
    filename = function() {
      new_name <- gsub(".csv", "", input$datafile)
      paste(new_name, '_adjusted.csv', sep='') 
    },
    content = function(file) {
      
      write.csv(geodata2(), file)
    }
  )
  
})