import mysql.connector
import xlsxwriter
from datetime import datetime

# Database connection settings
DBConfig = {
    'host': 'localhost',
    'user': 'root', # Insert MySQL username. "root" is default.
    'password': 'password', # Insert your password
    'database': 'groceryproject' # Insert database name
}

def restockSummary():
    """
    Connects to the database and retrieves a summary of restock data by product.
    """
    try:
        connection = mysql.connector.connect(**DBConfig)
        cursor = connection.cursor()

        # Query to get total restocks and number of restocks per product
        query = """
        SELECT 
            p.name AS Product, 
            COUNT(rl.log_id) AS RestockCount, 
            SUM(rl.quantity_added) AS TotalQuantity
        FROM 
            RestockLog rl
        JOIN 
            Products p 
        ON 
            rl.product_id = p.product_id
        GROUP BY 
            p.name
        ORDER BY 
            TotalQuantity DESC;
        """
        cursor.execute(query)
        results = cursor.fetchall()

        # Calculate total restock count for percentage calculation
        restocks = sum(row[1] for row in results)
        return results, restocks

    except mysql.connector.Error as err:
        print(f"Error: {err}")
        return [], 0

    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

def makeDocument(data, restocks):
    """
    Creates an Excel spreadsheet with restock data, including restock counts, percentages, and a pie chart.
    """
    filename = f"RestockSummary_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xlsx" # Sets the name with the current time and date
    workbook = xlsxwriter.Workbook(filename)
    worksheet = workbook.add_worksheet("Restock Summary")

    # Define header and formatting
    headers = ["Product", "Restock Count", "Total Quantity", "Percentage of Restocks"]
    formatBold = workbook.add_format({'bold': True, 'bg_color': '#D3D3D3', 'border': 1})
    formatPercent = workbook.add_format({'num_format': '0.00%', 'border': 1})

    # Set column widths to be wider
    worksheet.set_column(0, 0, 25)  # Product name width
    worksheet.set_column(1, 3, 25)  # Other column widths

    # Write headers
    for col_num, header in enumerate(headers):
        worksheet.write(0, col_num, header, formatBold)

    # Write data and calculate percentages
    for row_num, row in enumerate(data, start=1):
        product, restock_count, total_quantity = row
        percentage = restock_count / restocks if restocks > 0 else 0
        worksheet.write(row_num, 0, product)
        worksheet.write(row_num, 1, restock_count)
        worksheet.write(row_num, 2, total_quantity)
        worksheet.write(row_num, 3, percentage, formatPercent)

    # Create a pie chart
    chart = workbook.add_chart({'type': 'pie'})

    # Configure the chart with data
    chart.add_series({
        'name': 'Restock Summary',
        'categories': ['Restock Summary', 1, 0, len(data), 0],  # Products column
        'values':     ['Restock Summary', 1, 1, len(data), 1],  # Restock Count column
        'data_labels': {'percentage': True}  # Show percentages on the pie chart
    })

    # Add chart title and style
    chart.set_title({'name': 'Most Restocked Products'})
    chart.set_style(10)  # Predefined chart style

    # Insert chart further to the right to make room for data
    worksheet.insert_chart('H2', chart)

    workbook.close()
    print(f"Excel file with pie chart created: {filename}")

if __name__ == "__main__":
    # Fetch data and generate the spreadsheet
    print("Fetching summary data from the database...")
    data, restocks = restockSummary()

    if data:
        print("Data fetched successfully. Generating Excel file with chart...")
        makeDocument(data, restocks)
    else:
        print("No data to export.")
