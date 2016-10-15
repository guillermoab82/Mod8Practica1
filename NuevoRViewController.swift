//
//  NuevoRViewController.swift
//  Mod8Practica1
//
//  Created by Guillermo Alonso on 15/10/16.
//  Copyright © 2016 Guillermo ALonso. All rights reserved.
//

import UIKit
// Esto es un delegate (protocolo) NO HERENCIA multiple---<
class NuevoRViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    var estados:NSArray?
    var municipios:NSArray?
    var colonias:NSArray?
    var conexion:NSURLConnection?
    var datosRecibidos:NSMutableData!
    
    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtApellidos: UITextField!
    @IBOutlet weak var txtFechaNac: UITextField!
    @IBOutlet weak var txtCalleNum: UITextField!
    @IBOutlet weak var txtEstado: UITextField!
    @IBOutlet weak var txtMunicipio: UITextField!
    @IBOutlet weak var txtColonia: UITextField!
    @IBOutlet weak var pickerFN: UIDatePicker!
    @IBOutlet weak var pickerEstados: UIPickerView!
    @IBOutlet weak var pickerMunicipios: UIPickerView!
    @IBOutlet weak var pickerColonias: UIPickerView!
    
    @IBAction func pickerDateChange(sender: AnyObject) {
        let formato = NSDateFormatter()
        formato.dateFormat = "dd-MM-yyyy"
        let fechaString = formato.stringFromDate(self.pickerFN.date)
        self.txtFechaNac.text = fechaString
    }
    // Métodos necesarios para el UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if pickerEstados.isEqual(pickerView){
            return estados!.count
        }else if pickerMunicipios.isEqual(pickerView){
            return municipios!.count
        }else{
            return colonias!.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        if pickerEstados.isEqual(pickerView){
            return (estados![row].valueForKey("nombreEstado") as! String)
        }else if pickerMunicipios.isEqual(pickerView){
            return (municipios![row] as! String)
        }else{
            return (colonias![row] as! String)
        }
    }
    //HASTA AQUÍ LOS MÉTODOS DEL UIPickerViewDataSource
    
    
    func subeBajaPicker(elPicker:UIView,subeObaja:Bool) {
        var elFrame:CGRect = elPicker.frame
        UIView.animateWithDuration(0.5){
            if subeObaja {
                elFrame.origin.y = CGRectGetMaxY(self.txtFechaNac.frame)
                elPicker.hidden = false
            }else{
                elFrame.origin.y = CGRectGetMaxY(self.view.frame)
                elPicker.hidden = true
            }
            elPicker.frame = elFrame
            
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        //En codigo más swift
        /*return textField.isEqual(self.txtNombre) ||
            textField.isEqual(self.txtApellidos) ||
            textField.isEqual(self.txtCalleNum)
        */
        //En código general
        
        if textField.isEqual(self.txtNombre) ||
            textField.isEqual(self.txtApellidos) ||
            textField.isEqual(self.txtCalleNum){
            self.ocultaPickers()
            return true
        }else{
            self.txtNombre.resignFirstResponder()
            self.txtApellidos.resignFirstResponder()
            self.txtCalleNum.resignFirstResponder()
            if textField.isEqual(self.txtFechaNac){
                self.subeBajaPicker(self.pickerFN,subeObaja:true)
            }
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtNombre.delegate = self
        self.txtApellidos.delegate = self
        self.txtFechaNac.delegate = self
        self.txtCalleNum.delegate = self
        self.txtEstado.delegate = self
        self.txtMunicipio.delegate = self
        self.txtColonia.delegate = self
        self.pickerEstados.delegate = self
        self.pickerFN.hidden = true
        self.estados = NSArray()
        //Inicializamos con datos temporales
        self.municipios = ["Cd.Victoria","Matamoros","Reynosa"]//NSArray()
        self.colonias = ["San Rafael","San Carlos","Soto la Marina"]//NSArray()
        self.consultaEstados()
        // Do any additional setup after loading the view.
        self.pickerColonias.delegate = self
        self.pickerMunicipios.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.ocultaPickers()
    }
    
    func ocultaPickers() {
        var unFrame:CGRect
        unFrame = self.pickerFN.frame
        self.pickerFN.frame = CGRectMake(unFrame.origin.x, CGRectGetMaxY(self.view.frame), unFrame.size.width, unFrame.size.height)
        self.pickerFN.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func consultaEstados() {
        let urlString = "http://edg3.mx/webservicessepomex/WMRegresaEstados.php"
        let laURL = NSURL(string: urlString)!
        let elRequest = NSURLRequest(URL: laURL)
        self.datosRecibidos = NSMutableData(capacity: 0)
        self.conexion = NSURLConnection(request: elRequest, delegate: self)
        if self.conexion == nil {
            self.datosRecibidos = nil
            self.conexion = nil
            print("No se puede acceder al WS Estados")
        }else{
            
        }
    }
    
    func connection(connection:NSURLConnection,didFailWithError error:NSError) {
        self.datosRecibidos = nil
        self.conexion = nil
        print("No se puede acceder al WS Estados")
    }

    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse){
        //Ya se logro recibir los datos
        self.datosRecibidos?.length=0
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData){
        //Se recibió un paquete de datos, Guadarlo con los demás
        self.datosRecibidos?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection){
        do{
            let arregloRecibido = try NSJSONSerialization.JSONObjectWithData(self.datosRecibidos!, options: .AllowFragments) as! NSArray
            self.estados = arregloRecibido
            self.pickerEstados.reloadAllComponents()
        }catch{
            print("error en la serializacion")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
