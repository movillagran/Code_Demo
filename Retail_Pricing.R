

#Retail Price Monitor


library('rvest')

library('stringr')

library('RJSONIO')
library('bitops')
library('RCurl')
library('XML')


url<-'https://www.google.com/search?rlz=1C1GGRV_enUS748US749&biw=1536&bih=831&tbm=shop&q=pampers&oq=pampers&gs_l=psy-ab.3..0l10.157099.157322.0.158304.2.2.0.0.0.0.107.192.1j1.2.0....0...1.1.64.psy-ab..0.2.191....0.X8T5B3MAIFs'


GoogleShopping<-read_html(url)

item<-html_nodes(GoogleShopping,'.r')
name <- html_text(item)
name
length(name)
name <-substring(name,1,39)
name

item<-html_nodes(GoogleShopping,'.shop__secondary, b')
price<-html_text(item)
price

price<-gsub("Pampers","",price)

price<-gsub("pampers","",price)

price<-substring(price,2,6)


price<-na.omit(price)

price <-as.numeric(price)

price

length(price)



item<-html_nodes(GoogleShopping,'.shop__secondary .sh-rt__product, a')
review<-html_text(item)
review
review<-grep("*product reviews", review,value=T)

length(review)



#Combining all the lists to form a data frame
item_df<-data.frame(Today = format(Sys.time(), "%a %b %d %X %Y"), Name = name, Price = price)

item_df

write.csv(item_df, file= "C:/Users/mo.villigran/Documents/GitHub/R-Web-Scraping-Practice/Daily data/10_17_2017.csv")

str(item_df)


#Now put the resulting table to R Shiny App--still working on it

library('shiny')


# Define UI ----
ui <- fluidPage(
  titlePanel("Pricing Monitor--Mo Villagran"),
  
  sidebarLayout(
    sidebarPanel("sidebar panel"),
    mainPanel("main panel")
  )
  
)

# Define server logic ----
server <- function(input, output) {
  
}

# Run the app ----
shinyApp(ui = ui, server = server)
