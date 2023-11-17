const service = require('../services/user')

const User = new service.User()

let idToDelete;

describe('Creating User', () => {
    it('Should not create a user with the same email', async () => {
        const user = {
            email: "pepehaggeb@gmail.com",
            name: "Pedro Hagge Baptista",
            password: "123456",
        }

        try {
            const result = await User.Create(user.email, user.password, user.name)

            return expect(result.name).toBe(user.name)
        } catch (err) {
            return expect(err.message).toBe("User already exists")
        }
    })

    it('Should create a user', async () => {
        const user = {
            email: "pepehaggehb@gmail.com",
            name: "Pedro Hagge Baptista",
            password: "123456",
        }

        const result = await User.Create(user.email, user.name, user.password)

        idToDelete = result.id

        return expect(result.name).toBe(user.name)
    })
})

describe('Authenticating User', () => {
    it('Should auth a user by email and pass', async () => {
        const result = await User.Authenticate("pepehaggehb@gmail.com", "123456")

        return expect(result.id).toBe(idToDelete)
    })

    it('Should not auth a user that doesnt exists', async () => {
        const id = "a7f53818-fe6e-4fa7-a9e6-df88d7432ab0"

        try {
            const result = await User.Authenticate("teste", "teste")

            return expect(result.id).toBe(id)
        } catch (err) {

            console.log(err.message)

            return expect(err.message).toBe("Invalid Email or/and Password")
        }
    })
})

describe('Getting User', () => {
    it('Should get a user by id', async () => {
        const result = await User.Get(idToDelete)

        return expect(result.id).toBe(idToDelete)
    })

    it('Should not get a user that doesnt exists', async () => {
        const id = "a7f53818-fe6e-4fa7-a9e6-df88d7432ab0"

        try {
            const result = await User.Get(id)

            return expect(result.id).toBe(id)
        } catch (err) {
            return expect(err.message).toBe("Error: User not found")
        }
    })
})

describe('Updating User', () => {
    it("Should update an user by id", async () => {
        const user = {
            name: "Pedro Hagge Baptista",
        }

        const result = await User.Update(idToDelete, user)

        return expect(result.user.name).toBe(user.name)
    })

    it("Should not update an user that doesnt exists", async () => {
        const id = "a7f53818-fe6e-4fa7-a9e6-df88d7432ab0"

        const user = {
            name: "Pedro Hagge Baptista",
        }

        try {
            const result = await User.Update(id, user)

            return expect(result.id).toBe(id)
        } catch (err) {
            return expect(err.message).toBe("User not found")
        }
    })
})

describe('Deleting User', () => {
    it("Should delete an user by id", async () => {
        const result = await User.Remove(idToDelete)

        return expect(result.message).toBe("User removed successfully")
    })

    it("Should not delete an user that doesnt exists", async () => {
        const id = "a7f53818-fe6e-4fa7-a9e6-df88d7432ab0"

        try {
            const result = await User.Remove(id)

            return expect(result.message).toBe("User removed successfully")
        } catch (err) {
            return expect(err.message).toBe("User not found")
        }
    })
})