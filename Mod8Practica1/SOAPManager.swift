//
//  SOAPManager.swift
//  Mod8Practica1
//
//  Created by Guillermo Alonso on 21/10/16.
//  Copyright © 2016 Guillermo ALonso. All rights reserved.
//

import Foundation



public class SOAPManager: NSObject, NSURLConnectionDelegate, NSXMLParserDelegate {
    private let NODO_RESULTADOS = "NewDataSet"
    private let NODO_MUNICIPIO = "ReturnDataSet"
    
    private var municipios:NSMutableArray?
    private var municipio:NSMutableDictionary?
    private var guardaResultado:Bool = false
    private var esMunicipio:Bool = false
    private var nombreCampo:String = ""
    
    static let instance:SOAPManager = SOAPManager()
    private let wsURL = "http://edg3.mx/webservicessepomex/sepomex.asmx"
    private var datosRecibidos:NSMutableData!
    private var conexion:NSURLConnection?
    
    
    public func consultaMunicipios(estado:String){
        let soapMun1 = "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><WMRegresaMunicipios xmlns=\"http://tempuri.org/\"><c_estado>"
        
        let soapMun2 = "</c_estado></WMRegresaMunicipios></soap:Body></soap:Envelope>"
        
        let soapMessage = soapMun1 + estado + soapMun2
        
        let laURL = NSURL(string: self.wsURL)!
        let elRequest = NSMutableURLRequest(URL: laURL)
        elRequest.HTTPMethod = "POST"
        elRequest.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        let longitudMensaje = "\(soapMessage.characters.count)"
        elRequest.setValue(longitudMensaje, forHTTPHeaderField: "Content-Length")
        elRequest.setValue("http://tempuri.org/WMRegresaMunicipios", forHTTPHeaderField: "SOAPAction")
        elRequest.HTTPBody = soapMessage.dataUsingEncoding(NSUTF8StringEncoding)
        
        ///
        self.datosRecibidos = NSMutableData(capacity: 0)
        self.conexion = NSURLConnection(request: elRequest, delegate: self)
        if self.conexion == nil {
            self.datosRecibidos = nil
            self.conexion = nil
            print("No se puede acceder al WS Estados")
        }
    }
    
    public func connection(connection:NSURLConnection,didFailWithError error:NSError) {
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
        //SOAP response es un XML,implentar parseo
        let responseSTR = NSString(data: self.datosRecibidos!, encoding: NSUTF8StringEncoding)
        print(responseSTR)
        let xmlParser = NSXMLParser(data: self.datosRecibidos!)
        xmlParser.delegate = self
        xmlParser.shouldResolveExternalEntities = true
        xmlParser.parse()
    }
    public func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == NODO_RESULTADOS {
                guardaResultado = true
        }
        if guardaResultado && elementName == NODO_MUNICIPIO {
            self.municipio = NSMutableDictionary()
            esMunicipio = true
        }
        nombreCampo = elementName
    
    }
    public func parser(parser: NSXMLParser, foundCharacters string: String) {
        if esMunicipio {
            municipio!.setObject(string, forKey: nombreCampo)
        }
    }
    public func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == NODO_MUNICIPIO{
            if municipios == nil {
                municipios = NSMutableArray()
            }
            municipios?.addObject(municipio!)
            esMunicipio = false
        }
    }
    public func parserDidEndDocument(parser: NSXMLParser) {
        print("Resultado parseado: \(municipio?.description)")
    }
}
