import web

urls = (
  '/hello', 'Index'
)


app = web.application(urls, globals())

render = web.template.render('templates/')

class Index(object):
    def GET(self):
    	greeting = "Hello World"
    	return greeting
        

if __name__ == "__main__":
    app.run()