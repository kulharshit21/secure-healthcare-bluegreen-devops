#!/usr/bin/env python3
"""
Healthcare API Application
A secure Flask-based healthcare API demonstrating CI/CD and Blue-Green deployment
"""

import os
import json
from flask import Flask, jsonify, request
from datetime import datetime, timezone

app = Flask(__name__)

# Environment variables from ConfigMap and Secrets
APP_VERSION = os.getenv('APP_VERSION', 'unknown')
DEPLOYMENT_COLOR = os.getenv('DEPLOYMENT_COLOR', 'unknown')
ENVIRONMENT = os.getenv('ENVIRONMENT', 'development')
SERVICE_NAME = os.getenv('SERVICE_NAME', 'healthcare-api')

# In-memory patient database (for demo purposes only)
patients_db = [
    {
        "patient_id": "P001",
        "name": "John Doe",
        "age": 45,
        "condition": "Hypertension",
        "assigned_doctor": "Dr. Smith",
        "last_visit": "2026-04-28"
    },
    {
        "patient_id": "P002",
        "name": "Jane Smith",
        "age": 32,
        "condition": "Diabetes Type 2",
        "assigned_doctor": "Dr. Johnson",
        "last_visit": "2026-04-25"
    },
    {
        "patient_id": "P003",
        "name": "Robert Brown",
        "age": 58,
        "condition": "Cardiac Arrhythmia",
        "assigned_doctor": "Dr. Williams",
        "last_visit": "2026-04-26"
    }
]


@app.route('/', methods=['GET'])
def index():
    """Root endpoint - API information"""
    return jsonify({
        "app": SERVICE_NAME,
        "message": "Healthcare API - Secure Blue-Green Deployment Demo",
        "version": APP_VERSION,
        "environment": ENVIRONMENT,
        "deployment": DEPLOYMENT_COLOR,
        "timestamp": datetime.now(timezone.utc).isoformat()
    }), 200


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint - used by Kubernetes probes"""
    return jsonify({
        "status": "healthy",
        "service": SERVICE_NAME,
        "deployment": DEPLOYMENT_COLOR
    }), 200


@app.route('/version', methods=['GET'])
def version():
    """Version endpoint - returns deployment version"""
    return jsonify({
        "app": SERVICE_NAME,
        "version": APP_VERSION,
        "deployment": DEPLOYMENT_COLOR,
        "environment": ENVIRONMENT
    }), 200


@app.route('/patients', methods=['GET'])
def get_patients():
    """Retrieve all patients (dummy data)"""
    return jsonify({
        "status": "success",
        "count": len(patients_db),
        "patients": patients_db
    }), 200


@app.route('/patients', methods=['POST'])
def create_patient():
    """Create a new patient record (in-memory only)"""
    try:
        data = request.get_json(silent=True)
        
        # Validate required fields
        if not data or 'name' not in data or 'age' not in data:
            return jsonify({
                "status": "error",
                "message": "Missing required fields: name, age"
            }), 400
        
        # Create new patient
        new_patient = {
            "patient_id": f"P{len(patients_db) + 1:03d}",
            "name": data.get('name'),
            "age": data.get('age'),
            "condition": data.get('condition', 'Not specified'),
            "assigned_doctor": data.get('assigned_doctor', 'TBD'),
            "last_visit": datetime.now().strftime("%Y-%m-%d")
        }
        
        patients_db.append(new_patient)
        
        return jsonify({
            "status": "success",
            "message": "Patient record created",
            "patient": new_patient
        }), 201
    
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500


@app.route('/patients/<patient_id>', methods=['GET'])
def get_patient(patient_id):
    """Get a specific patient by ID"""
    for patient in patients_db:
        if patient['patient_id'] == patient_id:
            return jsonify({
                "status": "success",
                "patient": patient
            }), 200
    
    return jsonify({
        "status": "error",
        "message": f"Patient {patient_id} not found"
    }), 404


@app.route('/security-status', methods=['GET'])
def security_status():
    """Security status - demonstrate security practices"""
    return jsonify({
        "status": "success",
        "security_features": {
            "container": "running as non-root user",
            "secrets": "managed by Kubernetes Secret",
            "deployment": "blue-green strategy with zero-downtime updates",
            "vulnerability_scanning": "Trivy configured in Jenkins pipeline",
            "rbac": "Kubernetes RBAC enabled",
            "health_checks": "readiness and liveness probes enabled",
            "resource_limits": "CPU and memory limits configured",
            "network_policy": "example network policy provided"
        },
        "deployment_color": DEPLOYMENT_COLOR,
        "environment": ENVIRONMENT
    }), 200


@app.route('/metrics', methods=['GET'])
def metrics():
    """Basic metrics endpoint"""
    return jsonify({
        "status": "success",
        "metrics": {
            "total_patients": len(patients_db),
            "api_version": APP_VERSION,
            "deployment": DEPLOYMENT_COLOR
        }
    }), 200


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({
        "status": "error",
        "message": "Endpoint not found"
    }), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    return jsonify({
        "status": "error",
        "message": "Internal server error"
    }), 500


if __name__ == '__main__':
    # Only for development - in production use gunicorn
    debug_mode = ENVIRONMENT == 'development'
    app.run(host='0.0.0.0', port=5000, debug=debug_mode)
