from flask import Flask, render_template, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
import datetime

# Initialize Flask app and configure database URI
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///data.db'  # SQLite database file
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False  # To avoid warning
db = SQLAlchemy(app)

# Define the database model for the collected data
class ComputerInfo(db.Model):
    uuid = db.Column(db.String(100), primary_key=True)
    serial_number = db.Column(db.String(100), nullable=False)
    computer_name = db.Column(db.String(100), nullable=False)
    date = db.Column(db.DateTime, default=datetime.datetime.utcnow)
    ip_address = db.Column(db.String(15), nullable=False)
    mac_address = db.Column(db.String(17), nullable=False)

    def __repr__(self):
        return f"<ComputerInfo {self.serial_number} - {self.computer_name}>"

# Initialize the database (this creates the table if it doesn't exist)
with app.app_context():
    db.create_all()

# Home route to display all records
@app.route('/')
def index():
    # Get all records from the database
    computer_info = ComputerInfo.query.all()
    return render_template('index.html', computer_info=computer_info)

# Route to add new record
@app.route('/add', methods=['GET', 'POST'])
def add_info():
    if request.method == 'POST':
        # Get data from form
        uuid = request.form['uuid']
        serial_number = request.form['serial_number']
        computer_name = request.form['computer_name']
        ip_address = request.form['ip_address']
        mac_address = request.form['mac_address']
        
        # Create a new ComputerInfo object and save to the database
        new_computer = ComputerInfo(uuid=uuid,
                                    serial_number=serial_number, 
                                    computer_name=computer_name,
                                    ip_address=ip_address,
                                    mac_address=mac_address)
        db.session.add(new_computer)
        db.session.commit()

        return redirect(url_for('index'))
    
    return render_template('add.html')

# Run the app
if __name__ == '__main__':
    app.run(debug=True)
