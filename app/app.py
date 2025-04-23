from flask import Flask, render_template, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.exc import IntegrityError
import datetime, uuid, random
from faker import Faker
import plotly.express as px

# Faker til testdata
fake = Faker()

# Initialisere flask og database
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///data.db' 
# app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False  # To avoid warning
db = SQLAlchemy(app)

# ComputerInfo klassen
class ComputerInfo(db.Model):
    serial_number = db.Column(db.String(100), primary_key=True)
    uuid = db.Column(db.String(36), nullable=False)
    computer_name = db.Column(db.String(100), nullable=False)
    date = db.Column(db.DateTime, default=datetime.datetime.now)
    ip_address = db.Column(db.String(15), nullable=False)
    mac_address = db.Column(db.String(17), nullable=False)
    win_build = db.Column(db.String(10), nullable=False)
    win_ver = db.Column(db.String(12), nullable=False)
    win_name = db.Column(db.String(100), nullable=False)

    def __repr__(self):
        return f"<ComputerInfo {self.serial_number} - {self.computer_name}>"

# Initialisere database, opretter data.db og tabeller hvis de ikke eksisterer.
with app.app_context():
    db.create_all()

### Index ###
@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        serial_number = request.form['serial_number']
        print(serial_number)
        record_to_delete = ComputerInfo.query.filter_by(serial_number=serial_number).first()
        db.session.delete(record_to_delete)
        db.session.commit()


    # Get all records from the database
    computer_info = ComputerInfo.query.all()
    number_of_records = len(computer_info)
    print("Number fo records: ", number_of_records)
    # Tæl forskellige Windows-versioner
    win_ver_counts = db.session.query(ComputerInfo.win_ver, db.func.count(ComputerInfo.win_ver)).group_by(ComputerInfo.win_ver).all()
    # Prepare data for the pie chart
    data = {
        "Windows Version": [item[0] for item in win_ver_counts],
        "Count": [item[1] for item in win_ver_counts]
    }

    # Create the pie chart using Plotly Express
    pie_fig = px.pie(data,
                     names="Windows Version",
                     values="Count",
                     title="Windows Version Distribution",
                     height=410,
                     width=640)
    pie_fig.update_layout(
        plot_bgcolor="#f9f9f9",  # Background color of the plot area
        paper_bgcolor="#f9f9f9"  # Background color of the entire chart
    )

    return render_template('index.html', computer_info=computer_info, number_of_records=number_of_records, piechart=pie_fig.to_html())

### Tilføj computer ###
@app.route('/add', methods=['GET', 'POST'])
def add_info():
    if request.method == 'POST':
        # Get data from form
        uuid = request.form['uuid']
        serial_number = request.form['serial_number']
        computer_name = request.form['computer_name']
        ip_address = request.form['ip_address']
        mac_address = request.form['mac_address']
        win_name = request.form['win_name']
        win_ver = request.form['win_ver']
        win_build = request.form['win_build']
        
        # Opretter nyt ComputerInfo objekt og comitter til DB
        new_computer = ComputerInfo(uuid=uuid,
                                    serial_number=serial_number, 
                                    computer_name=computer_name,
                                    ip_address=ip_address,
                                    mac_address=mac_address,
                                    win_name=win_name,
                                    win_build=win_build,
                                    win_ver=win_ver)
        db.session.add(new_computer)
        db.session.commit()

        return redirect(url_for('index'))
    
    return render_template('add.html')

### Fyld databasen med testdata ###
@app.route('/addtestdata/<int:amount>')
def add_test_data(amount):
    for _ in range(amount):
        fake_uuid = str(uuid.uuid4())
        fake_serial_number = f"SN{random.randint(10000, 99999)}"
        fake_computer_name = f"TST-{fake_serial_number}"
        fake_ip_address = fake.ipv4(private=True)
        fake_mac_address = fake.mac_address().replace(':','-')
        fake_win_name = "Microsoft Windows 10 Pro"
        #fake_win_ver = "10.0.19044"
        fake_win_ver = "10.0.26100"
        fake_win_build = "19044"
        
        fake_computer = ComputerInfo(uuid=fake_uuid,
                            serial_number=fake_serial_number, 
                            computer_name=fake_computer_name,
                            ip_address=fake_ip_address,
                            mac_address=fake_mac_address,
                            win_name=fake_win_name,
                            win_build=fake_win_build,
                            win_ver=fake_win_ver)
        try:
            db.session.commit()
            db.session.add(fake_computer)
        except IntegrityError as e:
        ## Nogle gange finder den på det samme serienummer, det ignorerer vi.
            print(repr(e))
            db.session.rollback() 
            continue 
    return 'ok'

# Run the app
if __name__ == '__main__':
    app.run(debug=True)
