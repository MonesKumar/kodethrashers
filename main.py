from fastapi import *

app = FastAPI()

@app.route("/")
async def hello():
    return 