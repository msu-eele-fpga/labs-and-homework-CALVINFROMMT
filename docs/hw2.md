#  A first-level heading
## A second-level heading
## A third-level heading

### Bold Text
** This is bold text **
 
### Italicized text
* * Italicized text needs a space between the stars * *

### Quoting basic text
 > A line of text that is a quote needs the greater than carrot before the text.

Or using a single `backtick` will quote the single word.

### BlockQuotes
Using three single backquotes before and after will block
```
This will be quoted
into its own distinct 
blocks
```
### Syntax highlighting 
In fenced code 3 backticks include ruby 
```ruby
reguire 'redcarpet'
markdown = Redcarpet.new("Hello World!")
puts markdown.to_html
```

### To add ALERTS.

> [!NOTE] 
> Useful information a user should know easily if they are skimming.

> [!TIP] 
> Helpful advice to do something easily

> [!IMPORTANT] 
> Key information users need to know to achieve their goal.

> [!WARNING]
> Urgent info that needs immediate user attention to avoid problems.

> [!Caution]
> Advises about risks or negative outcomes of certain actions.    

### Tables

| FIRST HEADER | SECOND HEADER |
|--------------|---------------|
| Content Cell | Content Cell  |
| Content Cell | Content Cell  |


These will change size based on content.  

### Unordered Lists

Unordered lists by preceding one or more lines of text with a negative, astrix or plus

- George Washington
* John Adams
+ Thomas Jefferson

### Ordered List

Use numbers to order list

1. James Madison
2. James Monroe
3. John Quincy Adams

### Links 
To include links in the file use square brackets containing the name you want to be linked then parentheses with the link.

Just like linking [GITHUB](www.github.com)

### Images

To include an image by adding an eclamation point then wrap the alt text in square brackets.  This will be the text equivalent for the image.  Then follow with parentheses containing the link to the image.  

![Lab1 screenshot](docs/assets/Screenshot from 2024-08-27 11-46-24.png) 
