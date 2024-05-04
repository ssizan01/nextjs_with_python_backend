from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/api/python")
def hello_world():
    return jsonify({"message": "We are trying to send python backend to nextjs frontend"})