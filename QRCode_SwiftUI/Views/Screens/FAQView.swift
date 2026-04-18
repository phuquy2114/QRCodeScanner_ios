//
//  FAQView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 8/4/26.
//

import SwiftUI

struct FAQView: View {
    private(set) var items: [FAQItem] = [
        FAQItem(
            icon: "qrcode",
            question: "Code can't be read?",
            answer: "Make sure the QR code is well-lit and not damaged. Try adjusting the distance between your camera and the code. You can also try importing the image from your photo library."
        ),
        FAQItem(
            icon: "wifi",
            question: "Can't connect to Wi-Fi?",
            answer: "Ensure the QR code contains valid Wi-Fi credentials. Go to Settings → Wi-Fi and try connecting manually using the network name and password shown after scanning."
        ),
        FAQItem(
            icon: "link",
            question: "Have problem with the link you get?",
            answer: "Check your internet connection. If the link doesn't open, try copying it and pasting in your browser. Some links may be expired or restricted."
        ),
        FAQItem(
            icon: "info.circle.fill",
            question: "Need more information?",
            answer: "Visit our website or contact our support team. We're available 24/7 to help you with any questions or issues you may encounter while using the app."
        ),
        FAQItem(
            icon: "photo.stack.fill",
            question: "Convert a picture to a QR code?",
            answer: "Go to the Create tab, select 'Image' as the content type, then choose your photo from the library. The app will generate a QR code containing the image URL."
        ),
    ]
    @State private var showFeedback = false
    
    var body: some View {
        VStack {
            Spacer().frame(height: 20)
            ButtonTheme(title: "STILL HAVE PROBLEMS", onTap: {
                showFeedback = true
            })
            Spacer().frame(height: 16)
            
            List {
                ForEach(items) { item in
                    FAQItemCell(item: item)
                        .listRowBackground(Color.clear)
                        .listRowInsets(
                            EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                        )
                        
                }
            }
            .scrollContentBackground(.hidden)
            .listRowSeparator(.hidden)
            .listStyle(.plain)
            .listRowSpacing(16)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .marginBottom()
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("FAQ")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }
        .navigationDestination(isPresented: $showFeedback) {
            FeedbackView()
        }
    }
}

#Preview {
    NavigationStack {
        FAQView()
    }
}
