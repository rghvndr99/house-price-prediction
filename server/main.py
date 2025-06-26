from flask import Flask, jsonify, request
from flask_cors import CORS
from utils.index import loadModel,get_price,get_param

app = Flask(__name__)

# Configure CORS with specific settings
CORS(app)

@app.before_request
def load_model():
    loadModel()

@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization,Accept')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response

@app.route("/")
def root():
    return jsonify({"message": "Hello World"})

# Add endpoint that frontend expects
@app.route("/get-location")
def get_locations():
    prms=get_param()
    return jsonify({"locations": prms})

# Add health check endpoint
@app.route("/health")
def health_check():
    return "healthy", 200

# Add predict-price endpoint that frontend expects
@app.route("/predict-price", methods=["POST"])
def predict_price():
    try:
        data = request.get_json()

        if not data:
            return jsonify({"error": "No data provided"}), 400

        # Extract parameters from request
        location = data.get('location')
        total_sqft = data.get('total_sqft')
        bhk = data.get('bhk')
        bath = data.get('bath')

        # Validate required parameters
        if not all([location, total_sqft, bhk, bath]):
            return jsonify({"error": "Missing required parameters: location, total_sqft, bhk, bath"}), 400

        # Call the prediction function
        predicted_price = get_price(location, total_sqft, bhk, bath)

        return jsonify({
            "estimated_price": predicted_price,
            "confidence": 85,  # You can calculate actual confidence if available
            "location": location,
            "total_sqft": total_sqft,
            "bhk": bhk,
            "bath": bath
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8100, debug=True)