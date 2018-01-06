//
//  LoginViewController.swift
//  GameOfChats
//
//  Created by Seth Merritt on 12/14/17.
//  Copyright © 2017 leftyseth. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
	
	var messagesViewController: MessagesViewController?
	
	let inputsContainerView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.white
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 5
		view.layer.masksToBounds = true
		return view
	}()
	
	lazy var loginRegisterButton: UIButton = {
		let button = UIButton(type: .system)
		button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
		button.setTitle("Register", for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitleColor(UIColor.white, for: .normal)
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
		
		button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
		
		return button
	}()
	
	//checking if user is logged in.
	@objc func handleLoginRegister() {
		if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
			handleLogin()
		} else {
			handleRegister()
		}
	}
	
	@objc func handleLogin() {
		
		guard let email = emailTextField.text, let password = passwordTextField.text else {
			print("login error")
			return
		}
		
		Auth.auth().signIn(withEmail: email, password: password, completion: { ( user, error) in
			if error != nil {
				print(error!)
				return
			}
			//successfully logged in the user
			self.messagesViewController?.fetchUserAndSetupNavBarTitle()
			self.dismiss(animated: true, completion: nil)
			
		})
	}
	
	
	let nameTextField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "Name"
		tf.translatesAutoresizingMaskIntoConstraints = false
		return tf
	}()
	
	let nameSeparatorView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let emailTextField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "Email Address"
		tf.translatesAutoresizingMaskIntoConstraints = false
		return tf
	}()
	
	let emailSeparatorView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let passwordTextField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "Passowrd"
		tf.translatesAutoresizingMaskIntoConstraints = false
		tf.isSecureTextEntry = true
		return tf
	}()
	
	lazy var profileImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "splash")
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		
		imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
		imageView.isUserInteractionEnabled = true
		
		return imageView
	}()
	
	lazy var loginRegisterSegmentedControl: UISegmentedControl = {
		let sc = UISegmentedControl(items: ["Login", "Register"])
		sc.translatesAutoresizingMaskIntoConstraints = false
		sc.tintColor = UIColor.white
		sc.selectedSegmentIndex = 1
		sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
		return sc
	}()
	
	//changes the number of fields from login to register.
	@objc func handleLoginRegisterChange() {
		let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
		loginRegisterButton.setTitle(title, for: .normal)
		
		//change height of input container view. If it is logn, then its 100, otherwise it is 150 height
		inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
		
		//change height of nameTextfield
		nameTextFieldHeightAnchor?.isActive = false
		nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
		nameTextFieldHeightAnchor?.isActive = true
		
		//change height of emailTextfield
		emailTextFieldHeightAnchor?.isActive = false
		emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
		emailTextFieldHeightAnchor?.isActive = true
		
		//change height of passwordTextfield
		passwordTextFieldHeightAnchor?.isActive = false
		passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
		passwordTextFieldHeightAnchor?.isActive = true
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
		
		view.addSubview(inputsContainerView)
		view.addSubview(loginRegisterButton)
		view.addSubview(profileImageView)
		view.addSubview(loginRegisterSegmentedControl)
		
		setupInputsContainerView()
		setupLoginRegisterButton()
		setupProfileImageView()
		setupLoginRegisterSegmentedControl()
		
	}
	
	//toggles the register/sign in buttons
	func setupLoginRegisterSegmentedControl() {
		loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
		loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
		loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
		
	}
	
	func setupProfileImageView() {
		profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
		profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
		profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
	}
	
	var inputsContainerViewHeightAnchor: NSLayoutConstraint?
	var nameTextFieldHeightAnchor: NSLayoutConstraint?
	var emailTextFieldHeightAnchor: NSLayoutConstraint?
	var passwordTextFieldHeightAnchor: NSLayoutConstraint?
	
	
	func setupInputsContainerView() {
		//need x, v, width and height constraints to create the login views.
		inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
		inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
		inputsContainerViewHeightAnchor?.isActive = true
		
		inputsContainerView.addSubview(nameTextField)
		nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
		nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
		nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
		
		nameTextFieldHeightAnchor =	nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
		nameTextFieldHeightAnchor?.isActive = true
		
		inputsContainerView.addSubview(nameSeparatorView)
		nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
		nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
		nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
		nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		inputsContainerView.addSubview(emailTextField)
		emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
		emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
		emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
		emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
		emailTextFieldHeightAnchor?.isActive = true
		
		inputsContainerView.addSubview(emailSeparatorView)
		emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
		emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
		emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
		emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
		
		inputsContainerView.addSubview(passwordTextField)
		passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
		passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
		passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
		passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
		passwordTextFieldHeightAnchor?.isActive = true
	}

	func setupLoginRegisterButton() {
		loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
		loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
		loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}

extension UIColor {
	//creates an autocomplete on the UI Color methods
	convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
	self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
	}

}
