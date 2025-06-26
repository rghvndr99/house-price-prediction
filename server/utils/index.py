import json
import os
import pickle
import numpy as np
model=None
data_columns=[]

def loadModel():
    global model
    global data_columns
    if model is None:
        with open('../model/dwelling_model.pickle','rb') as f:
            model=pickle.load(f)
        print("model loaded successfully")
    if len(data_columns) == 0:
        with open('../model/columns.json','r') as f:
            data=json.load(f)
            data_columns=data.get('data_columns',[])
        print("location loaded successfully")
def get_price(location,sqrt,bhk,bath): 
    try:
        loc_index= data_columns.index(location.lower())
    except:
        loc_index=-1
    x=np.zeros(len(data_columns))
    x[0]=sqrt
    x[1]=bath
    x[2]=bhk
    if loc_index>=0:
        x[loc_index]=1
    return round(model.predict([x])[0], 2)

def get_param():
    return data_columns[3:]
