"""
Unit tests for Healthcare API
Test all critical endpoints
"""

import pytest
from app import app, patients_db


@pytest.fixture
def client():
    """Create test client"""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


class TestHealthcareAPI:
    """Test cases for Healthcare API"""

    def test_root_endpoint(self, client):
        """Test GET / endpoint"""
        response = client.get('/')
        assert response.status_code == 200
        data = response.get_json()
        assert 'app' in data
        assert 'message' in data
        assert 'version' in data
        assert data['app'] == 'healthcare-api'

    def test_health_endpoint(self, client):
        """Test GET /health endpoint"""
        response = client.get('/health')
        assert response.status_code == 200
        data = response.get_json()
        assert data['status'] == 'healthy'
        assert 'service' in data
        assert 'deployment' in data

    def test_version_endpoint(self, client):
        """Test GET /version endpoint"""
        response = client.get('/version')
        assert response.status_code == 200
        data = response.get_json()
        assert 'app' in data
        assert 'version' in data
        assert 'deployment' in data
        assert 'environment' in data

    def test_get_patients(self, client):
        """Test GET /patients endpoint"""
        response = client.get('/patients')
        assert response.status_code == 200
        data = response.get_json()
        assert data['status'] == 'success'
        assert 'count' in data
        assert 'patients' in data
        assert data['count'] >= 0

    def test_create_patient_success(self, client):
        """Test POST /patients with valid data"""
        patient_data = {
            "name": "Test Patient",
            "age": 35,
            "condition": "Test Condition",
            "assigned_doctor": "Dr. Test"
        }
        response = client.post('/patients', json=patient_data)
        assert response.status_code == 201
        data = response.get_json()
        assert data['status'] == 'success'
        assert 'patient' in data

    def test_create_patient_missing_fields(self, client):
        """Test POST /patients with missing required fields"""
        patient_data = {"name": "Test Patient"}
        response = client.post('/patients', json=patient_data)
        assert response.status_code == 400
        data = response.get_json()
        assert data['status'] == 'error'

    def test_create_patient_no_data(self, client):
        """Test POST /patients with no data"""
        response = client.post('/patients', json=None)
        assert response.status_code == 400

    def test_get_patient_found(self, client):
        """Test GET /patients/<id> with existing patient"""
        response = client.get('/patients/P001')
        assert response.status_code == 200
        data = response.get_json()
        assert data['status'] == 'success'
        assert 'patient' in data

    def test_get_patient_not_found(self, client):
        """Test GET /patients/<id> with non-existing patient"""
        response = client.get('/patients/PXXX')
        assert response.status_code == 404
        data = response.get_json()
        assert data['status'] == 'error'

    def test_security_status_endpoint(self, client):
        """Test GET /security-status endpoint"""
        response = client.get('/security-status')
        assert response.status_code == 200
        data = response.get_json()
        assert data['status'] == 'success'
        assert 'security_features' in data
        assert 'container' in data['security_features']

    def test_metrics_endpoint(self, client):
        """Test GET /metrics endpoint"""
        response = client.get('/metrics')
        assert response.status_code == 200
        data = response.get_json()
        assert data['status'] == 'success'
        assert 'metrics' in data

    def test_404_endpoint(self, client):
        """Test non-existent endpoint"""
        response = client.get('/nonexistent')
        assert response.status_code == 404
        data = response.get_json()
        assert data['status'] == 'error'


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
