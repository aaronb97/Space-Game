import csv, io, json 
with open("/Users/aaronbecker/Desktop/horizons_results.txt","r") as source:
    data = source.read()
    data = data.replace("A.D.", "")
    data = data.replace("00:00:00.0000", "")
    data = data.replace("Jan", "1")
    data = data.replace("Feb", "2")
    data = data.replace("Mar", "3")
    data = data.replace("Apr", "4")
    data = data.replace("May", "5")
    data = data.replace("Jun", "6")
    data = data.replace("Jul", "7")
    data = data.replace("Aug", "8")
    data = data.replace("Sep", "9")
    data = data.replace("Oct", "10")
    data = data.replace("Nov", "11")
    data = data.replace("Dec", "12")
    data = data.replace(" ", "")
    data = data.replace('\r', '')
    data2 = data.split('$$SOE')
    data3 = data2[1].split('$$EOE')
    data4 = data3[0].split('\n')
    res = [sub[ : -1] for sub in data4]
    n = "\n"
    data5 = n.join(res)
    data5 = data5.strip()
    rdr= csv.reader(io.StringIO(data5) )
    with open("/Users/aaronbecker/Desktop/converted.txt","w") as result:
        result.write("date,x,y,z\n")
        wtr= csv.writer( result )
        for r in rdr:
            wtr.writerow( (r[1], r[2], r[3], r[4]) )
        result.close()


    with open("/Users/aaronbecker/Desktop/converted.txt","r") as f:
        reader = csv.DictReader(f)
        with open("/Users/aaronbecker/Desktop/converted.json","w") as result:
            result.write('{\n"positions": {')
            for row in reader:
#json.dump(row['date'] : {'x' : row['x'], "y" : row['y'], "z" : row['z']}, result)
#result.write(f'"row["date"]" : {\n"x" : "{row["x"]}",\n"y" : "{row["y"]}"\n},')
                result.write('"')
                result.write(f'{row["date"]}')
                result.write('" : {\n    "x" : "')
                result.write(f'{row["x"]}')    
                result.write('", \n    "y" : "')
                result.write(f'{row["y"]}')    
                result.write('", \n    "z" : "')
                result.write(f'{row["z"]}')    

                result.write('"},\n')
                
            result.write('}}')


    f = open("/Users/aaronbecker/Desktop/converted.json","r") 
    filestring = f.read()
    f.close()

    newfilestring = filestring.replace(",\n}", "}")
    f = open("/Users/aaronbecker/Desktop/converted.json","w") 
    f.write(newfilestring)
    f.close()

    
        

    
#with open("/Users/aaronbecker/Desktop/converted.txt","w") as result:
#       json.dump(rows, result)

