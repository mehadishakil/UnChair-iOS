//
//  VerificationView.swift
//  UnChair-iOS
//
//  Created by Mehadi Hasan on 3/6/25.
//



import SwiftUI

struct VerificationView: View {
    
    @State var one: String = ""
    @State var two: String = ""
    @State var three: String = ""
    @State var four: String = ""
    
    var body: some View {
        VStack {
            VStack() {
                Text("Verification Code")
                    .font(.title2.weight(.semibold))
                    .padding(.bottom, 2)
                Text("Enter the code we sent to your email")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            Spacer()
                .frame(height:40)
            
            
            VStack {
                ZStack {
                    HStack(spacing: 20) {
                
                            TextField("", text: $one)
                                .padding()
                                .background(Color.gray3)
                                .foregroundColor(Color.black)
                                .frame(width: 50)
                                .cornerRadius(6)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                                .overlay( /// apply a rounded border
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.gray6, lineWidth: 1)
                                )
                            
                            TextField("", text: $two)
                                .padding()
                                .background(Color.gray3)
                                .foregroundColor(Color.black)
                                .frame(width: 50)
                                .cornerRadius(6)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                                .overlay( /// apply a rounded border
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.gray6, lineWidth: 1)
                                )
       
                            
                            TextField("", text: $three)
                                .padding()
                                .background(Color.gray3)
                                .foregroundColor(Color.black)
                                .frame(width: 50)
                                .cornerRadius(6)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                                .overlay( /// apply a rounded border
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.gray6, lineWidth: 1)
                                )
    
                            
                            TextField("", text: $four)
                                .padding()
                                .background(Color.gray3)
                                .foregroundColor(Color.black)
                                .frame(width: 50)
                                .cornerRadius(6)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                                .overlay( /// apply a rounded border
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.gray6, lineWidth: 1)
                                )
                    }
                            
                }
                            
            }
            
            Spacer()


            Button(
                action: {
                    // add action here
                },
                label: {
                    HStack{
                        Text("Next")
                            .bold()
                            .foregroundColor(Color.whiteblack)
                    }
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color.BW)
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.gray6, lineWidth: 1)
                    )
                })
            
            Spacer()
                .frame(height: 15)
            
            
            // Legal Disclaimer
            Text("Resend in 5 sec")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.top, 10)
                .font(.subheadline)
                .frame(width: 250)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

struct VerificationView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationView()
    }
}

